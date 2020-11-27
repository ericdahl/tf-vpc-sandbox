provider "aws" {
  region = "us-east-1"
}

resource "aws_ec2_transit_gateway" "default" {
  tags = {
    Name = "tf-vpc-sandbox"
  }
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}
