Notes:



vars:
- source bucket arn
- dest bucket arn 

TODO:
- import existing bucket
- IAM roles for cross account data sync 
- 


what i did:
- manually create new 'source' s3 bucket "annalise-ai-datalake-lol"
- add terrafrom resource aws_s3_bucket.source
- import  bucket into terraform with 'terraform import aws_s3_bucket.source annalise-ai-datalake-lol'




RESOURCES:

- https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/
- https://stackoverflow.com/questions/72315660/import-an-existing-bucket-in-terraform
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task
