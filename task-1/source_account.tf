import {
  to = aws_s3_bucket.source
  id = "annalise-ai-datalake-lol"
}

resource "aws_s3_bucket" "source" {
  provider = aws.source
}
