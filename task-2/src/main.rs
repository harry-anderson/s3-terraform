use aws_config::meta::region::RegionProviderChain;
use aws_sdk_s3::{config::Region, Client, Error};
use structopt::StructOpt;
use tracing::info;

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

    let Opt {
        region,
        bucket,
    } = Opt::from_args();

    let region_provider = RegionProviderChain::first_try(region.map(Region::new))
        .or_default_provider()
        .or_else(Region::new("us-east-1"));
    let shared_config = aws_config::from_env().region(region_provider).load().await;
    let client = Client::new(&shared_config);

    let res = show_objects(&client, &bucket).await;
}

// Lists the objects in a bucket.
async fn show_objects(client: &Client, bucket: &str) -> Result<(), Error> {
    let resp = client.list_objects_v2().bucket(bucket).send().await?;

    for object in resp.contents().unwrap_or_default() {
        info!("{}", object.key().unwrap_or_default());
    }

    Ok(())
}
