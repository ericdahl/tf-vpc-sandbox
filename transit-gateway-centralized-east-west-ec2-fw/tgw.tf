resource "aws_ec2_transit_gateway" "default" {
  default_route_table_association = "disable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-centralized-east-west-fw"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "fw_propagation_table" {
  transit_gateway_attachment_id  = module.vpc_fw.tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.default.propagation_default_route_table_id
}
