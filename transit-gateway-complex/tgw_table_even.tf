resource "aws_ec2_transit_gateway_route_table" "even" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "even"
  }
}

resource "aws_ec2_transit_gateway_route" "even_blackhole" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.even.id
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "even_10_2_0_0" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.even.id
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0.id
}

resource "aws_ec2_transit_gateway_route" "even_10_4_0_0" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.even.id
  destination_cidr_block         = "10.4.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_4_0_0.id
}

resource "aws_ec2_transit_gateway_route_table_association" "even_10_2_0_0" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.even.id
}

resource "aws_ec2_transit_gateway_route_table_association" "even_10_4_0_0" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_4_0_0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.even.id
}

