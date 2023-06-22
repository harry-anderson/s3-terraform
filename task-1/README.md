## Task 1
note: sorry im not familliar with using terraform inside docker. I have listed the steps just using terraform installed on my local machine.

### How to import buckets
To import the existing resources i have used a `import` block in `main.tf`. 
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
To copy data between the buckets I would use a cross-account [AWS DataSync Task](https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/)
I had a go at creating the a template for the DataSync resouces, although i couldnt getting working in my testing due to cross account IAM issues, see `task-1/extra_resources`

Why?
- Full managed solution, avoid the need for manage and scale a compute cluster.
- Easy to setup, just need IAM permissions in both accounts

Alternatives considered:
- Use AWS s3 Batch operations
- custom compute cluster to copy the data between buckets






RESOURCES:

1 - https://aws.amazon.com/blogs/storage/how-to-use-aws-datasync-to-migrate-data-between-amazon-s3-buckets/
2 - https://stackoverflow.com/questions/72315660/import-an-existing-bucket-in-terraform
3 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task
4 - https://developer.hashicorp.com/terraform/language/import
5 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
6 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
7 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy.html

