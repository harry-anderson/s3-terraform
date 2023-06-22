import {
  to = aws_s3_bucket.dest
  id = "harrison-ai-landing-lol"
}

resource "aws_s3_bucket" "dest" {
  provider = aws.dest
}
