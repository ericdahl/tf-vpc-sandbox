provider "aws" {
  region = "us-east-1"
}

resource "aws_ec2_transit_gateway" "default" {}

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
