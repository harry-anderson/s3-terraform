Notes:



vars:
- source bucket arn
- dest bucket arn 

TODO:
- import existing bucket
- IAM roles for cross account data sync 
- 


what I did:
- manually create new `source` s3 bucket "annalise-ai-datalake-lol"
- manually create new `dest` s3 bucket "harrison-ai-landing-lol"
- created terraform import blocks and matching resource blocks for source and dest buckets
- create two seperate aws providers `source` and `dest`
- import existing buckets with `terraform plan`, accept then `terraform show`




RESOURCES:

- https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/
- https://stackoverflow.com/questions/72315660/import-an-existing-bucket-in-terraform
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task
- https://developer.hashicorp.com/terraform/language/import
