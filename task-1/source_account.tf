import {
  to = aws_s3_bucket.source
  id = "annalise-ai-datalake-lol"
}

resource "aws_s3_bucket" "source" {
  provider = aws.source
}

# IAM
resource "aws_iam_role" "source_role" {
  provider = aws.source
  name = "source_bucket_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::${aws_s3_bucket.dest.arn}"]
        },
        {
          Action = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListMultipartUploadParts",
            "s3:PutObject",
            "s3:GetObjectTagging",
            "s3:PutObjectTagging"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::${aws_s3_bucket.dest.arn}/*"]
        },

      ]
    })
  }
}
