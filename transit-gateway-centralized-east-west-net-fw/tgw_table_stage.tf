resource "aws_ec2_transit_gateway_route_table" "stage" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "stage"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "stage" {
  for_each = {
    "vpc_10.10.0.0" : module.vpc_10_10_0_0.tgw_attachment_id
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.stage.id
}


# default route to funnel all TGW traffic to the centralized networking VPC
# for filtering, etc
resource "aws_ec2_transit_gateway_route" "stage" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.stage.id

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.fw.id
}