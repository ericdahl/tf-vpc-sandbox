output "tgw_attachment" {
  value = module.base_vpc.tgw_attachment
}

output "subnets" {
  value = module.base_vpc.subnets
}

output "ec2_jumphost" {
  value = module.base_vpc.ec2_jumphost
}

output "ec2_internal" {
  value = module.base_vpc.ec2_internal
}

output "vpc" {
  value = module.base_vpc.vpc
}

output "route_tables" {
  value = {
    public  = module.base_vpc.route_tables.public
    private = module.base_vpc.route_tables.private
    tgw     = module.base_vpc.route_tables.tgw
  }
}

output "nat_gw" {
  value = aws_nat_gateway.fw
}