provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-centralized-nat"
    }
  }
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ami" "pfsense" {
  owners = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "product-code"
    values = ["cphb99lr7icr3n9x6kc3102s5"]
  }

  filter {
    name   = "name"
    values = ["pfSense-plus-ec2-21.05.1-RELEASE-amd64*"]
  }
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}