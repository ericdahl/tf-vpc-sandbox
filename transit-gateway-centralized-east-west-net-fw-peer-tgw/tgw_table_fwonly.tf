resource "aws_ec2_transit_gateway_route_table" "fwonly" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "fwonly"
  }
}


# default route to funnel all TGW traffic to the centralized networking VPC
# for filtering, etc
resource "aws_ec2_transit_gateway_route" "fwonly" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fwonly.id

  transit_gateway_attachment_id = module.vpc_fw.tgw_attachment.id
}

resource "aws_ec2_transit_gateway_route_table_association" "fwonly_external" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.external.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fwonly.id
}
