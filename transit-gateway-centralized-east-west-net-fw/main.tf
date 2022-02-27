provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-centralized-east-west-net-fw"
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

module "vpc_dev" {
  source = "./vpc/workload"

  for_each = toset([
    "10.1.0.0/16",
    "10.2.0.0/16",
    "10.3.0.0/16",
    "10.4.0.0/16",
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key
}

module "vpc_stage" {
  source = "./vpc/workload"

  for_each = toset([
    "10.10.0.0/16",
  ])

  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key
}

module "vpc_fw" {
  source = "./vpc/fw"

  cidr_block = "10.111.0.0/16"
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  aws_network_firewall = aws_networkfirewall_firewall.default
}