
resource "aws_ec2_transit_gateway_route_table" "central" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  tags = {
    Name = "central"
  }
}

resource "aws_ec2_transit_gateway_route" "central_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central.id

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.r10_111_0_0.id
}


resource "aws_ec2_transit_gateway_route" "central_vpc" {
  for_each = {
        "vpc_10.1.0.0" : { "cidr" : "10.1.0.0/16", "attachment_id" : aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0_new.id }
        "vpc_10.2.0.0" : { "cidr" : "10.2.0.0/16", "attachment_id" : aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0_new.id }
        "vpc_10.10.0.0" : { "cidr" : "10.10.0.0/16", "attachment_id" : aws_ec2_transit_gateway_vpc_attachment.r10_10_0_0_new.id }
  }

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central.id
  transit_gateway_attachment_id  = each.value.attachment_id
  destination_cidr_block         = each.value.cidr
}


resource "aws_ec2_transit_gateway_route_table_propagation" "central" {
  for_each = {
    "vpc_10.111.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_111_0_0
  }
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central.id
  transit_gateway_attachment_id  = each.value.id
}

resource "aws_ec2_transit_gateway_route_table_association" "central" {
  for_each = {
    "vpc_10.111.0.0" : aws_ec2_transit_gateway_vpc_attachment.r10_111_0_0
  }

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central.id
}
