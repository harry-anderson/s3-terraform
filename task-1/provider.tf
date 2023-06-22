terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = local.source.region
  profile = local.source.profile
}

provider "aws" {
  alias = "source"
  region  = local.source.region
  profile = local.source.profile
}

provider "aws" {
  alias = "dest"
  region  = local.dest.region
  profile = local.dest.profile
}
