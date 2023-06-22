// imported bucket
// terraform import aws_s3_bucket.source annalise-ai-datalake-lol
resource "aws_s3_bucket" "source" {
  bucket = local.source_bucket
}
