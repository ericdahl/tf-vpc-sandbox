resource "aws_ec2_transit_gateway_route_table" "odd" {
  transit_gateway_id = "${aws_ec2_transit_gateway.default.id}"

  tags = {
    Name = "odd"
  }
}

resource "aws_ec2_transit_gateway_route" "odd_blackhole" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
  destination_cidr_block = "0.0.0.0/0"
  blackhole = true
}

resource "aws_ec2_transit_gateway_route" "odd_10_1_0_0" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_1_0_0.id}"
}

resource "aws_ec2_transit_gateway_route" "odd_10_3_0_0" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_3_0_0.id}"
}

resource "aws_ec2_transit_gateway_route" "odd_10_5_0_0" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
  destination_cidr_block = "10.5.0.0/16"
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_5_0_0.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "odd_10_1_0_0" {
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_1_0_0.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "odd_10_3_0_0" {
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_3_0_0.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "odd_10_5_0_0" {
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_5_0_0.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odd.id}"
}