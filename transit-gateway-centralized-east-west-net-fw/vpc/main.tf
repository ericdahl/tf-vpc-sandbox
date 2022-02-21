locals {
  public_subnet_cidrs  = [for s in range(0, 3) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  private_subnet_cidrs = [for s in range(128, 131) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  tgw_subnet_cidrs = [for s in range(132, 135) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
}

data "aws_availability_zones" "default" {}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.cidr_block
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  vpc_id             = aws_vpc.default.id
  transit_gateway_id = var.tgw_id

  subnet_ids = [for s in aws_subnet.tgw : s.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = aws_vpc.default.cidr_block
  }
}