module "base_vpc" {
  source = "../base"


  admin_ip_cidr = var.admin_ip_cidr
  cidr_block    = var.cidr_block
  public_key    = var.public_key
  tgw_id        = var.tgw_id
}

resource "aws_eip" "fw" {
  vpc        = true
  depends_on = [module.base_vpc.igw]
}

resource "aws_nat_gateway" "fw" {
  allocation_id = aws_eip.fw.id
  subnet_id     = module.base_vpc.subnets.public["us-east-1a"].id
}

resource "aws_route" "private_default_natgw" {
  route_table_id = module.base_vpc.route_tables.private.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.fw.id
}

#resource "aws_route" "private_rfc1918_tgw" {
#  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])
#
#  route_table_id = module.base_vpc.route_tables.private.id
#
#  destination_cidr_block = each.value
#  transit_gateway_id     = var.tgw_id
#}

resource "aws_route" "tgw_rfc1918_tgw" {
  # if need to bypass FW, can add rfc1918 (more specific) routes to go directly back to TGW
  for_each = var.enable_firewall_inter_vpc ? toset([]) : toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = module.base_vpc.route_tables.tgw.id

  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
}

# Used for EC2 based firewalls, without VPC Endpoint
resource "aws_route" "tgw_default" {

  route_table_id = module.base_vpc.route_tables.tgw.id

  destination_cidr_block = "0.0.0.0/0"

  # Used for EC2 based firewalls, without VPC Endpoint
  network_interface_id = var.tgw_default_route_fw_eni == null ? null : var.tgw_default_route_fw_eni.id

  ## Used for AWS Network Firewall integration with VPE Endpoint
  vpc_endpoint_id = var.tgw_default_route_fw_vpc_endpoint == null ? null : var.tgw_default_route_fw_vpc_endpoint.endpoint_id
}

resource "aws_route" "private_rfc1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = module.base_vpc.route_tables.private.id

  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
}