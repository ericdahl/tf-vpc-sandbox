resource "aws_vpc" "vpc_10_2_0_0" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "10.2.0.0/16"
  }
}

resource "aws_subnet" "vpc_10_2_0_0_public1" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "vpc_10_2_0_0_private1" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "vpc_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
}

resource "aws_route_table" "vpc_10_2_0_0_public" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_10_2_0_0.id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.default.id
  }
}

resource "aws_route_table" "vpc_10_2_0_0_private" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
}

resource "aws_route_table_association" "vpc_10_2_0_0_sub1" {
  route_table_id = aws_route_table.vpc_10_2_0_0_public.id
  subnet_id      = aws_subnet.vpc_10_2_0_0_public1.id
}

resource "aws_route_table_association" "vpc_10_2_0_0_private_sub1" {
  route_table_id = aws_route_table.vpc_10_2_0_0_private.id
  subnet_id      = aws_subnet.vpc_10_2_0_0_private1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_10_2_0_0" {
  vpc_id             = aws_vpc.vpc_10_2_0_0.id
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  subnet_ids = [
    aws_subnet.vpc_10_2_0_0_private1.id,
  ]
}

