## Task 2
### make fake files in s3
```
cd files/
aws s3 sync . s3://<your bucket>
```

### Run the script
Assuming your queue and bucket are in the same `region`.
```
cargo run -- --region us-east-1 --bucket harryloltest --queue-url https://sqs... --prefix prefix_a

```
```
2023-06-23T23:39:21.161403Z  INFO task_2: queued prefix_a/4 7eda628e-3058-4f3b-9a25-0ace2e639d41 b8c3d44c0fa829c9bf9f6e301561daae
2023-06-23T23:39:21.169658Z  INFO task_2: queued prefix_a/1 a6716bf1-0d1e-4c87-88ee-f669896d86d1 5fc6c5030798ddf7be4eb1026fd0eb20
2023-06-23T23:39:21.171239Z  INFO task_2: queued prefix_a/3 c9118b0a-ebae-4912-9ebf-ab28cdfa06fa 54f1c368a002e4c25acc02353a2c674d
2023-06-23T23:39:21.171904Z  INFO task_2: queued prefix_a/5 8f357273-c280-42ab-bdb7-e7c91b0f1cb7 bb5cdc6c09df644a0023185009d8a40c
2023-06-23T23:39:21.172399Z  INFO task_2: queued prefix_a/2 a537a1c2-6519-43a3-b205-2ea7c87c4054 db0747686736cd9fa5988552e2f88653

```

### How it works
Two async tasks:
- `pager` pages through s3 keys using [list_objects_v2](https://docs.rs/aws-sdk-s3/latest/aws_sdk_s3/operation/list_objects_v2/builders/struct.ListObjectsV2FluentBuilder.html) and send each key over a channel to `sender`.
- `sender` sends the keys as messages to SQS and (possibly) handles deduplication and resending failed messages.

```

pager -> channel -> sender -> sqs

```

### Speed up the bucket listing process for very large buckets containing millions of objects

Limits:
- Paging: Limited to about 1000 keys per page
- Sending: I'm not sure there is a quota limit on sending messages (max / messages per second).

I would try to divide the bucket keys into chunks/shards and then have a pool of `pager`s, each listing a unqiue shard of s3 keys concurrently.

How to Divide keys?
- Using prefixes eg `pager_1` gets `prefix_a/` and `pager_2` gets `prefix_b/`. They page together and not worry about colliding.
- `ListObjectsV2` API returns keys in a specific order. So you can using the `start_after` and `max_keys` parameters to divide the keys into chunks.

### Make the process idempotent
To make the process idempotent, I would introduce a `cache` layer. The type of cache I think depends on if you need Strong or Eventual consistency e.g how important is deduplication of keys?.
The `sender` checks if the key is in the `cache` before sending the message to SQS.

```

pager -> channel -> sender -> cache -> sqs

```

### RESOURCES USED
aws rust sdk examples
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/sqs
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/s3
- https://docs.rs/aws-sdk-s3/latest/aws_sdk_s3/operation/list_objects_v2/builders/struct.ListObjectsV2FluentBuilder.html
- https://docs.aws.amazon.com/AmazonS3/latest/userguide/ListingKeysUsingAPIs.html

rust semaphore
- https://github.com/tokio-rs/tokio/discussions/2648
