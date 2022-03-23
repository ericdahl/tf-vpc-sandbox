module "vpc" {
  source = "../../modules/vpc/workload"

  for_each = toset([
    "172.31.0.0/16"
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.external.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  tgw_default_route_association = true
  tgw_default_route_propagation = true
}
