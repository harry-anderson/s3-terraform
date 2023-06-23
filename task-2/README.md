## Task 2
### make fake files in s3
```
cd files/
aws s3 sync . s3://harryloltest
```

### Run the script
```
cargo run -- --region us-east-1 --bucket harryloltest
```
