resource "aws_ec2_transit_gateway" "default" {
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-custom"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "main"
  }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  for_each = {
    "vpc_10.1.0.0": aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0
    "vpc_10.2.0.0": aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0
  }
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id = each.value.id
}

resource "aws_ec2_transit_gateway_route_table_association" "default" {
  for_each = {
    "vpc_10.1.0.0": aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0
    "vpc_10.2.0.0": aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0
  }

  transit_gateway_attachment_id = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}