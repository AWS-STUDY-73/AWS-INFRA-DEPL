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
access_key = "$AWS_ACCESS_KEY_ID"
secret_key = "$AWS_SECRET_ACCESS_KEY"
}
