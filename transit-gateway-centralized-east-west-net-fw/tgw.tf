resource "aws_ec2_transit_gateway" "default" {
  default_route_table_association = "disable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-centralized-east-west-fw"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "central" {
  for_each = {
    "vpc_10.111.0.0" : module.vpc_fw.tgw_attachment
  }

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.default.propagation_default_route_table_id
}
