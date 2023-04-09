locals {
  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]
}

# extremely minimal VPC for demo
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(local.availability_zones, local.public_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${aws_vpc.default.cidr_block}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-public"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}


resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}



#
#resource "aws_subnet" "public" {
#  vpc_id            = aws_vpc.default.id
#  availability_zone = "us-east-1a"
#
#  cidr_block = "10.0.0.0/24"
#  map_public_ip_on_launch = true
#}
#
#resource "aws_subnet" "public2" {
#  vpc_id            = aws_vpc.default.id
#  availability_zone = "us-east-1a"
#
#  cidr_block = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#}
#

#
#resource "aws_route_table" "public" {
#  vpc_id = aws_vpc.default.id
#}
#
#resource "aws_route_table" "public2" {
#  vpc_id = aws_vpc.default.id
#}
#
#resource "aws_route_table_association" "public" {
#  route_table_id = aws_route_table.public.id
#  subnet_id      = aws_subnet.public.id
#}
#
#resource "aws_route_table_association" "public2" {
#  route_table_id = aws_route_table.public2.id
#  subnet_id      = aws_subnet.public.id
#}
#
#resource "aws_route" "public_igw" {
#  route_table_id         = aws_route_table.public.id
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = aws_internet_gateway.default.id
#}