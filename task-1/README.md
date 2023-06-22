## Task 1
> Please note: I was not familiar with using terraform and docker-compose. I have used terraform on my local machine for this task.

### How to import buckets
To import the existing resources I have used an `import` block in `main.tf`. 
So to run the import, you can use `plan` and `apply` commands to manage to import.
Once applied the imported bucket is managed under this terraform environment.
```bash
cd task-1/

# init terraform
terraform init

# plan import
terraform plan

# apply import
terraform apply
```

### Copying data
To copy data between the buckets I would use a cross-account [AWS DataSync Task](https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/).

I had a go at creating the a template for the DataSync resouces ( see `task-1/extra_resources`). Although I run into cross account IAM issues while testing.

Why?
- Full managed solution, avoid the need for manage and scale a compute cluster.
- Easy to setup, just need IAM permissions in both accounts
- One-time or scheduled syncing

Alternatives considered:
- Use AWS s3 Batch operations
- custom compute cluster to copy the data between buckets






RESOURCES USED:

- https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/
- https://stackoverflow.com/questions/72315660/import-an-existing-bucket-in-terraform
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task
- https://developer.hashicorp.com/terraform/language/import
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy.html

