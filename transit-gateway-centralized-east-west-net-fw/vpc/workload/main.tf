module "base_vpc" {
  source = "../base"


  admin_ip_cidr = var.admin_ip_cidr
  cidr_block    = var.cidr_block
  public_key    = var.public_key
  tgw_id        = var.tgw_id
}

variable "cidr_block" {}
variable "tgw_id" {}
variable "admin_ip_cidr" {}
variable "public_key" {}


resource "aws_route" "private_default_tgw" {
  route_table_id = module.base_vpc.route_tables.private.id

  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.base_vpc.tgw_attachment.transit_gateway_id
}

resource "aws_route" "tgw_default_tgw" {
  route_table_id = module.base_vpc.route_tables.tgw.id

  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.base_vpc.tgw_attachment.transit_gateway_id
}