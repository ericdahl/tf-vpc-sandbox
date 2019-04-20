provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc_peering_connection" "default" {
  vpc_id      = "${aws_vpc.10_1_0_0.id}"
  peer_vpc_id = "${aws_vpc.10_2_0_0.id}"
}

resource "aws_vpc_peering_connection_accepter" "default" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.default.id}"
  auto_accept               = true
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
