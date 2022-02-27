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

variable "aws_network_firewall" {}


resource "aws_eip" "fw" {
  vpc        = true
  depends_on = [module.base_vpc.igw]
}

resource "aws_nat_gateway" "fw" {
  allocation_id = aws_eip.fw.id
  subnet_id     = module.base_vpc.subnets.public["us-east-1a"].id
}


resource "aws_route" "private_default_tgw" {
  route_table_id = module.base_vpc.route_tables.private.id

  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.base_vpc.tgw_attachment.transit_gateway_id
}

# diff from fw vpc
## fw - default to FW / rfc 1918 to TGW
## priv - default to TGW
resource "aws_route" "tgw_default_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = module.base_vpc.route_tables.tgw.id

  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
  //    network_interface_id = aws_network_interface.pfsense_10_111_0_0.id
}

resource "aws_route" "tgw_default_firewall" {
  route_table_id = module.base_vpc.route_tables.tgw.id

  destination_cidr_block = "0.0.0.0/0"
#  vpc_endpoint_id        = tolist(aws_networkfirewall_firewall.default.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  vpc_endpoint_id = tolist(var.aws_network_firewall.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
}

output "vpc" {
  value = module.base_vpc.vpc
}