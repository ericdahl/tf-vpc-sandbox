locals {
  public_subnet_cidrs  = [for s in range(0, 3) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  private_subnet_cidrs = [for s in range(128, 131) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
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

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.public_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cidr_block}-public"
  }
}


resource "aws_subnet" "private" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.private_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cidr_block}-private"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route" "public_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.public.id

  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "private_default_tgw" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
}


resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  vpc_id             = aws_vpc.default.id
  transit_gateway_id = var.tgw_id

  subnet_ids = [for s in aws_subnet.private : s.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = var.cidr_block
  }
}