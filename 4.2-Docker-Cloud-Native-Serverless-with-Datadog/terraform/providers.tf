terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.31.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}