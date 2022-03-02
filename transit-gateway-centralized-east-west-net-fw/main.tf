provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-centralized-east-west-net-fw"
    }
  }
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

module "vpc_dev" {
  source = "../modules/vpc/workload"

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
  source = "../modules/vpc/workload"

  for_each = toset([
    "10.10.0.0/16",
  ])

  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key
}

module "vpc_fw" {
  source = "../modules/vpc/fw"

  cidr_block = "10.111.0.0/16"
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  aws_network_firewall = aws_networkfirewall_firewall.default
}