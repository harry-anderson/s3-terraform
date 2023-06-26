
data "aws_caller_identity" "source" {}
# IAM
resource "aws_iam_role" "datasync_dest_access" {
  provider = aws.source
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
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
            "s3:ListObjectsV2",
            "s3:ListBucketMultipartUploads"
          ]
          Effect   = "Allow"
          Resource = [aws_s3_bucket.dest.arn]
        },
        {
          Action = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListObjectsV2",
            "s3:ListMultipartUploadParts",
            "s3:PutObject",
            "s3:GetObjectTagging",
            "s3:PutObjectTagging"
          ]
          Effect   = "Allow"
          Resource = ["${aws_s3_bucket.dest.arn}/*"]
        },

      ]
    })
  }
}

resource "aws_iam_role" "datasync_source_access" {
  provider = aws.source
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
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
          Resource = [aws_s3_bucket.dest.arn]
        },
        {
          Action = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListMultipartUploadParts",
            "s3:PutObjectTagging",
            "s3:GetObjectTagging",
            "s3:PutObject"
          ]
          Effect   = "Allow"
          Resource = ["${aws_s3_bucket.dest.arn}/*"]
        },

      ]
    })
  }
}

## DATA SYNC
resource "aws_datasync_location_s3" "source" {
  provider      = aws.source
  s3_bucket_arn = aws_s3_bucket.source.arn
  subdirectory  = "/"
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_source_access.arn
  }
}


resource "aws_datasync_task" "example" {
  provider      = aws.source
  source_location_arn      = aws_datasync_location_s3.source.arn
  destination_location_arn = aws_datasync_location_s3.dest.arn

  options {
    bytes_per_second = -1
  }
}
