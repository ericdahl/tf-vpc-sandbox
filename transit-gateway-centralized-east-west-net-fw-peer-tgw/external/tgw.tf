resource "aws_ec2_transit_gateway" "external" {
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-centralized-east-west-fw-peer-tgw-ext"
  }
}

resource "aws_ec2_transit_gateway_route" "external_default" {

  transit_gateway_route_table_id = aws_ec2_transit_gateway.external.association_default_route_table_id
  destination_cidr_block         = "0.0.0.0/0"

  transit_gateway_attachment_id = "tgw-attach-01b3c80e6cbbe5bec"

}