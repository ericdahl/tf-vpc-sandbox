resource "aws_ec2_transit_gateway_route_table" "dev" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "dev"
  }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev" {
  for_each = {
    "vpc_10.1.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0
    "vpc_10.2.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0
  }
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  transit_gateway_attachment_id  = each.value.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev" {
  for_each = {
    "vpc_10.1.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0
    "vpc_10.2.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0
  }

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}



resource "aws_ec2_transit_gateway_route" "dev" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.r10_111_0_0.id

}