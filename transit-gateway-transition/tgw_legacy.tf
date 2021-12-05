resource "aws_ec2_transit_gateway" "legacy" {
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-legacy"
  }
}

resource "aws_ec2_transit_gateway_route_table" "legacy" {
  transit_gateway_id = aws_ec2_transit_gateway.legacy.id

  tags = {
    Name = "transit-gateway-legacy"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "legacy" {
  for_each = {
    "vpc_10.1.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0_legacy
    "vpc_10.2.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0_legacy
    "vpc_10.10.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_10_0_0_legacy
  }

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.legacy.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "legacy" {
  for_each = {
    "vpc_10.1.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0_legacy
    "vpc_10.2.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0_legacy
    "vpc_10.10.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_10_0_0_legacy
  }

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.legacy.id
}