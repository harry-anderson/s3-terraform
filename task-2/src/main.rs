use aws_config::meta::region::RegionProviderChain;
use aws_sdk_s3::config::Region;
use aws_sdk_s3::Error;
use serde::Serialize;
use std::sync::Arc;
use structopt::StructOpt;
use tokio::sync::mpsc::{channel, Receiver, Sender};
use tokio::sync::Semaphore;
use tracing::{error, info};

#[derive(Debug, StructOpt)]
struct Opt {
    /// The AWS Region.
    #[structopt(short, long)]
    region: Option<String>,

    /// The name of the bucket.
    #[structopt(short, long)]
    bucket: String,

    /// The name of the sqs queue URL
    #[structopt(short, long)]
    queue_url: String,
}

#[derive(Debug, Serialize)]
struct Message {
    bucket: String,
    key: String,
}

#[tokio::main]
async fn main() {
    // Logging
    tracing_subscriber::fmt::init();

    // Read args
    let Opt {
        region,
        bucket,
        queue_url,
    } = Opt::from_args();

    // setup AWS clients
    let region_provider = RegionProviderChain::first_try(region.map(Region::new))
        .or_default_provider()
        .or_else(Region::new("us-east-1"));
    let shared_config = aws_config::from_env().region(region_provider).load().await;
    let s3_client = aws_sdk_s3::Client::new(&shared_config);
    let sqs_client = aws_sdk_sqs::Client::new(&shared_config);

    // two async tasks connected with channel
    let (tx, rx) = channel::<Message>(2000);
    let list_obj = tokio::spawn(enumerate_objects(s3_client, bucket, tx));
    let push_sqs = tokio::spawn(push_sqs(sqs_client, queue_url, rx));

    // run tasks and drop the result for now
    let (_, _) = tokio::join! {
        list_obj,
        push_sqs
    };
}

// Lists the objects in a bucket.
async fn enumerate_objects(
    client: aws_sdk_s3::Client,
    bucket: String,
    tx: Sender<Message>,
) -> Result<(), Error> {
    let mut marker: Option<String> = None;
    loop {
        let resp = client
            .list_objects_v2()
            // .max_keys(3) // for testing
            .set_continuation_token(marker)
            .bucket(&bucket)
            .send()
            .await?;

        for object in resp.contents().unwrap_or_default() {
            match object.key() {
                None => error!("obj has no key",),
                Some(key) => {
                    let msg = Message {
                        bucket: bucket.clone(),
                        key: key.to_string(),
                    };
                    if tx.send(msg).await.is_err() {
                        error!("receiver droppped")
                    }
                }
            }
        }

        // if last page of data, break
        // else update the marker
        if resp.is_truncated() {
            marker = resp.next_continuation_token().map(String::from)
        } else {
            break Ok(());
        }
    }
}

// Push keys to sqs
async fn push_sqs(
    client: aws_sdk_sqs::Client,
    queue_url: String,
    mut rx: Receiver<Message>,
) -> Result<(), Error> {
    // limit inflight tasks
    let count = 2000;
    let client = Arc::new(client);
    let semaphore = Arc::new(Semaphore::new(count));
    let mut join_handles = Vec::new();

    while let Some(msg) = rx.recv().await {
        let permit = semaphore.clone().acquire_owned().await.unwrap();
        let queue_url_c = queue_url.clone();
        let client_c = client.clone();
        join_handles.push(tokio::spawn(async move {
            // send to sqs
            let json = serde_json::to_string(&msg).unwrap();
            let rsp = client_c
                .send_message()
                .queue_url(queue_url_c)
                .message_body(&json)
                .send()
                .await;

            // log the queued message or error
            match rsp {
                Ok(resp) => {
                    let id = resp.message_id().unwrap_or_default();
                    let md5 = resp.md5_of_message_body().unwrap_or_default();
                    info!("queued {} {} {}", msg.key, id, md5);
                }
                Err(e) => {
                    // Should handle resending msg here
                    error!("queue failed {:?}", e);
                }
            }

            // explicitly own `permit` in the task
            drop(permit);
        }));
    }

    for handle in join_handles {
        handle.await.unwrap();
    }

    Ok(())
}
