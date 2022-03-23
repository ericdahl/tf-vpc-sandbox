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


resource "aws_ec2_transit_gateway_peering_attachment" "external" {
  transit_gateway_id      = aws_ec2_transit_gateway.default.id

  peer_region             = "us-east-1"
  peer_transit_gateway_id = module.external.tgw.id
}


resource "aws_ec2_transit_gateway_route" "external" {
  destination_cidr_block         = "172.31.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.default.propagation_default_route_table_id

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.external.id
}