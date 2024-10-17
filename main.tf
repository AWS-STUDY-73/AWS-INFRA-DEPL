provider "aws" {
  region = "us-east-1"
}



# Create AWS ec2 instance
resource "aws_instance" "myFirstInstance" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name	= "Recover_key"
}
