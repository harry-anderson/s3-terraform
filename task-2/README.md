## Task 2
### make fake files in s3
```
cd files/
aws s3 sync . s3://<your bucket>
```

### Run the script
Assuming your queue and bucket are in the same `region`
```
cargo run -- --region us-east-1 --bucket <your bucket> --queue-url <https://sqs...>
```

### RESOURCES USED
aws rust sdk examples
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/sqs
- https://github.com/awslabs/aws-sdk-rust/tree/main/examples/s3

rust semaphore
- https://github.com/tokio-rs/tokio/discussions/2648
