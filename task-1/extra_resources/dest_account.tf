# s3 bucket
# Bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_source" {
  provider = aws.dest
  bucket   = aws_s3_bucket.dest.id
  policy   = data.aws_iam_policy_document.allow_access_from_source.json
}

data "aws_iam_policy_document" "allow_access_from_source" {
  provider = aws.dest
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.datasync_source_access.arn]
    }
    actions = [
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
    resources = [
      aws_s3_bucket.dest.arn,
      "${aws_s3_bucket.dest.arn}/*"
    ]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "${data.aws_caller_identity.source.account_id}"
      ]
    }
    actions = [
      "s3:ListObjectsV2",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.dest.arn,
      "${aws_s3_bucket.dest.arn}/*"
    ]
  }
}

// Data sync destination location
resource "aws_datasync_location_s3" "dest" {
  provider      = aws.dest
  s3_bucket_arn = aws_s3_bucket.dest.arn
  subdirectory  = "/${aws_s3_bucket.source.id}"
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_dest_access.arn
  }
}
