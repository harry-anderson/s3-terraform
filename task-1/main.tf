# source account
import {
  to = aws_s3_bucket.source
  id = "annalise-ai-datalake-lol"
}

# destination account
import {
  to = aws_s3_bucket.dest
  id = "harrison-ai-landing-lol"
}

# resouces
resource "aws_s3_bucket" "source" {
  provider = aws.source
}

resource "aws_s3_bucket" "dest" {
  provider = aws.dest
}
