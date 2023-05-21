provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-centralized-east-west-net-fw"
    }
  }
}

locals {
  cidrs_rfc_1918 = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
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

  tgw_default_route_fw_vpc_endpoint = module.net_fw.vpc_endpoints
}

module "net_fw" {
  source = "../modules/net-fw"

  vpc_id = module.vpc_fw.vpc.id
  subnet_ids = [
    module.vpc_fw.subnets.private["us-east-1a"].id
  ]
}


# Hacky test about bypassing FW for saving money on particular endpoint
#resource "aws_route" "bypass_fw" {
#  route_table_id = module.vpc_fw.route_tables.tgw.id
#
#  destination_cidr_block = "93.184.216.34/32" # example.com
#  nat_gateway_id = module.vpc_fw.nat_gw.id
#}
###
#resource "aws_route" "bypass_fw_return" {
#
#  route_table_id = module.vpc_fw.route_tables.public.id
#
#  destination_cidr_block = "${module.vpc_dev["10.1.0.0/16"].ec2_internal.private_ip}/32"
##  destination_cidr_block = "10.0.0.0/9"
#  transit_gateway_id =  aws_ec2_transit_gateway.default.id
#}
