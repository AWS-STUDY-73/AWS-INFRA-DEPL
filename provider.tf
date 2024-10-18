terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
access_key = "AKIA2UC3CDS2PUO4EPOS"
secret_key = "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"
}
