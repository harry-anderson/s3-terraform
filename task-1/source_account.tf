import {
  to = aws_s3_bucket.source
  id = "annalise-ai-datalake-lol"
}

resource "aws_s3_bucket" "source" {
  provider = aws.source
}

# IAM
data "aws_iam_policy_document" "dest_bucket_iam_doc" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.dest.arn}"]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.dest.arn}/*"]
  }

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

# resource "aws_iam_policy" "dest_bucket" {
#   policy = data.aws_iam_policy_document.dest_bucket_iam_doc.json
# }

resource "aws_iam_role" "dest_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
