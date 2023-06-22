# import existing bucket from source account
import {
  to = aws_s3_bucket.source
  id = "annalise-ai-datalake-lol"
}

# imported bucket resource
resource "aws_s3_bucket" "source" {
  provider = aws.source
  acl      = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# existing bucket already managed in another terrraform project
# incase we need to reference the destination name
data "aws_s3_bucket" "dest" {
  bucket = "harrison-ai-landing-lol"
}
