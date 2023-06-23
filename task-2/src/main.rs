use aws_config::meta::region::RegionProviderChain;
use aws_sdk_s3::{config::Region, Client, Error};
use structopt::StructOpt;
use tokio::sync::mpsc::{channel, Receiver, Sender, UnboundedReceiver, UnboundedSender};
use tracing::{error, info};

#[derive(Debug, StructOpt)]
struct Opt {
    /// The AWS Region.
    #[structopt(short, long)]
    region: Option<String>,

    /// The name of the bucket.
    #[structopt(short, long)]
    bucket: String,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let (tx, rx) = channel(256);
    let list_obj = tokio::spawn(enumerate_objects(tx));
    let push_sqs = tokio::spawn(push_sqs(rx));

    tokio::select! {
        _ = list_obj => {}
        _ = push_sqs => {}
    };
}

// Lists the objects in a bucket.
async fn enumerate_objects(tx: Sender<String>) -> Result<(), Error> {
    let Opt { region, bucket } = Opt::from_args();
    let region_provider = RegionProviderChain::first_try(region.map(Region::new))
        .or_default_provider()
        .or_else(Region::new("us-east-1"));
    let shared_config = aws_config::from_env().region(region_provider).load().await;
    let client = Client::new(&shared_config);
    let resp = client.list_objects_v2().bucket(bucket).send().await?;

    for object in resp.contents().unwrap_or_default() {
        match object.key() {
            None => error!("obj has no key",),
            Some(s) => {
                if tx.send(s.to_string()).await.is_err() {
                    error!("receiver droppped")
                }
            }
        }
    }

    Ok(())
}

// Push keys to sqs
async fn push_sqs(mut rx: Receiver<String>) -> Result<(), Error> {
    while let Some(key) = rx.recv().await {
        info!("push {}", key)
    }

    Ok(())
}
