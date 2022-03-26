provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "single-vpc-fw"
    }
  }
}

locals {
  public_subnet_cidrs  = [for s in range(0, 3) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  private_subnet_cidrs = [for s in range(128, 131) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  fw_subnet_cidrs     = [for s in range(132, 135) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


data "aws_ami" "freebsd" {
  owners = [
    782442783595
  ]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["FreeBSD 13.0-RELEASE-amd64"]
  }

  most_recent = true
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.cidr_block
  }
}

resource "aws_flow_log" "default" {
  vpc_id       = aws_vpc.default.id
  traffic_type = "ALL"

  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

