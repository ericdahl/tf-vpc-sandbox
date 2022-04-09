module "base_vpc" {
  source = "../base"


  admin_ip_cidr = var.admin_ip_cidr
  cidr_block    = var.cidr_block
  public_key    = var.public_key
  tgw_id        = var.tgw_id

  availability_zones = var.availability_zones
  ec2_jumphost_az = var.ec2_jumphost_az
  ec2_internal_az = var.ec2_internal_az

  tgw_default_route_association = var.tgw_default_route_association
  tgw_default_route_propagation = var.tgw_default_route_propagation
}

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

resource "aws_route" "public_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = module.base_vpc.route_tables.public.id

  destination_cidr_block = each.value
  transit_gateway_id     = module.base_vpc.tgw_attachment.transit_gateway_id
}
