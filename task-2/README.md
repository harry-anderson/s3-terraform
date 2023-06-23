## Task 2
### make fake files in s3
```
cd files/
aws s3 sync . s3://<your bucket>
```

### Run the script
Assuming your queue and bucket are in the same `region`.
```
cargo run -- --region us-east-1 --bucket harryloltest --queue-url https://sqs.us-east-1.amazonaws.com/962586598999/MyQueue --prefix prefix_a

```
```
2023-06-23T23:39:21.161403Z  INFO task_2: queued prefix_a/4 7eda628e-3058-4f3b-9a25-0ace2e639d41 b8c3d44c0fa829c9bf9f6e301561daae
2023-06-23T23:39:21.169658Z  INFO task_2: queued prefix_a/1 a6716bf1-0d1e-4c87-88ee-f669896d86d1 5fc6c5030798ddf7be4eb1026fd0eb20
2023-06-23T23:39:21.171239Z  INFO task_2: queued prefix_a/3 c9118b0a-ebae-4912-9ebf-ab28cdfa06fa 54f1c368a002e4c25acc02353a2c674d
2023-06-23T23:39:21.171904Z  INFO task_2: queued prefix_a/5 8f357273-c280-42ab-bdb7-e7c91b0f1cb7 bb5cdc6c09df644a0023185009d8a40c
2023-06-23T23:39:21.172399Z  INFO task_2: queued prefix_a/2 a537a1c2-6519-43a3-b205-2ea7c87c4054 db0747686736cd9fa5988552e2f88653

```

### RESOURCES USED
aws rust sdk examples
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/sqs
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/s3

rust semaphore
- https://github.com/tokio-rs/tokio/discussions/2648
