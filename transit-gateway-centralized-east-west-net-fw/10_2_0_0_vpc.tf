resource "aws_vpc" "r10_2_0_0" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "10.2.0.0/16"
  }
}

resource "aws_subnet" "r10_2_0_0_public1" {
  vpc_id = aws_vpc.r10_2_0_0.id

  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_2_0_0_public2" {
  vpc_id                  = aws_vpc.r10_2_0_0.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_2_0_0_public3" {
  vpc_id                  = aws_vpc.r10_2_0_0.id
  cidr_block              = "10.2.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_2_0_0_private1" {
  vpc_id            = aws_vpc.r10_2_0_0.id
  cidr_block        = "10.2.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "r10_2_0_0_private2" {
  vpc_id            = aws_vpc.r10_2_0_0.id
  cidr_block        = "10.2.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "r10_2_0_0_private3" {
  vpc_id            = aws_vpc.r10_2_0_0.id
  cidr_block        = "10.2.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "r10_2_0_0" {
  vpc_id = aws_vpc.r10_2_0_0.id
}

resource "aws_route_table" "r10_2_0_0_public" {
  vpc_id = aws_vpc.r10_2_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.r10_2_0_0.id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.default.id
  }

  tags = {
    Name = "r10_2_0_0_public"
  }
}

resource "aws_route_table" "r10_2_0_0_private" {
  vpc_id = aws_vpc.r10_2_0_0.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.default.id
  }

  tags = {
    Name = "r10_2_0_0_private"
  }
}

resource "aws_route_table_association" "r10_2_0_0_sub1" {
  route_table_id = aws_route_table.r10_2_0_0_public.id
  subnet_id      = aws_subnet.r10_2_0_0_public1.id
}

resource "aws_route_table_association" "r10_2_0_0_sub2" {
  route_table_id = aws_route_table.r10_2_0_0_public.id
  subnet_id      = aws_subnet.r10_2_0_0_public2.id
}

resource "aws_route_table_association" "r10_2_0_0_sub3" {
  route_table_id = aws_route_table.r10_2_0_0_public.id
  subnet_id      = aws_subnet.r10_2_0_0_public3.id
}

resource "aws_route_table_association" "r10_2_0_0_private_sub1" {
  route_table_id = aws_route_table.r10_2_0_0_private.id
  subnet_id      = aws_subnet.r10_2_0_0_private1.id
}

resource "aws_route_table_association" "r10_2_0_0_private_sub2" {
  route_table_id = aws_route_table.r10_2_0_0_private.id
  subnet_id      = aws_subnet.r10_2_0_0_private2.id
}

resource "aws_route_table_association" "r10_2_0_0_private_sub3" {
  route_table_id = aws_route_table.r10_2_0_0_private.id
  subnet_id      = aws_subnet.r10_2_0_0_private3.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "r10_2_0_0" {
  vpc_id             = aws_vpc.r10_2_0_0.id
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  subnet_ids = [
    aws_subnet.r10_2_0_0_private1.id,
    aws_subnet.r10_2_0_0_private2.id,
    aws_subnet.r10_2_0_0_private3.id,
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "10.2.0.0/16"
  }
}

resource "aws_flow_log" "r10_2_0_0" {
  vpc_id          = aws_vpc.r10_2_0_0.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
}


