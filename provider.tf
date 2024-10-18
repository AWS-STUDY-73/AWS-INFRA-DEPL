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
}
