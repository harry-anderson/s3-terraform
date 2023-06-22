import {
  to = aws_s3_bucket.dest
  id = "harrison-ai-landing-lol"
}

resource "aws_s3_bucket" "dest" {
  provider = aws.dest
}

resource "aws_iam_role" "dest_role" {
  provider = aws.dest
  name     = "dest_bucket_role"
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
          Principal = {
            "AWS" : aws_iam_role.source_role.arn
          }
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListMultipartUploadParts",
            "s3:PutObject",
            "s3:GetObjectTagging",
            "s3:PutObjectTagging"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.dest.arn}",
            "arn:aws:s3:::${aws_s3_bucket.dest.arn}/*"
          ]
        },
      ]
    })
  }
}
