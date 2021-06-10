provider "aws" {
  region = "us-east-1"
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


resource "aws_key_pair" "default" {
  public_key = var.key_pair_public
}