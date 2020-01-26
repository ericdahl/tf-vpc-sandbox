provider "aws" {
  region = "us-east-1"
}

resource "aws_ec2_transit_gateway" "default" {

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "transit-gateway-custom"
  }
}


resource "aws_ec2_transit_gateway_route_table" "odds" {
  transit_gateway_id = "${aws_ec2_transit_gateway.default.id}"

  tags = {
    Name = "odds"
  }
}

resource "aws_ec2_transit_gateway_route" "odds_blackhole" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odds.id}"
  destination_cidr_block = "0.0.0.0/0"
  blackhole = true
}

resource "aws_ec2_transit_gateway_route" "odds_10_1_0_0" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odds.id}"
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_1_0_0.id}"
}

resource "aws_ec2_transit_gateway_route" "odds_10_3_0_0" {
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odds.id}"
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_3_0_0.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "odds_10_1_0_0" {
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_1_0_0.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odds.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "odds_10_3_0_0" {
  transit_gateway_attachment_id = "${aws_ec2_transit_gateway_vpc_attachment.10_3_0_0.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.odds.id}"
}


data "aws_ami" "freebsd_11" {
  most_recent = true

  owners = ["118940168514"]

  filter {
    name = "name"

    values = [
      "FreeBSD 11.1-STABLE-amd64*",
    ]
  }
}
