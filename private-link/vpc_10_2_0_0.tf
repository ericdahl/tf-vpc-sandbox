resource "aws_vpc" "vpc_10_2_0_0" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "10.2.0.0/16"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public1_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2_10_2_0_0" {
  vpc_id                  = aws_vpc.vpc_10_2_0_0.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public3_10_2_0_0" {
  vpc_id                  = aws_vpc.vpc_10_2_0_0.id
  cidr_block              = "10.2.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1_10_2_0_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private2_10_2_0_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private3_10_2_0_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "gw_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
}

resource "aws_route_table" "public_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_10_2_0_0.id
  }
}

resource "aws_route_table" "private_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default_10_2_0_0.id
  }
}

resource "aws_route_table_association" "sub1_10_2_0_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public1_10_2_0_0.id
}

resource "aws_route_table_association" "sub2_10_2_0_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public2_10_2_0_0.id
}

resource "aws_route_table_association" "sub3_10_2_0_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public3_10_2_0_0.id
}

resource "aws_route_table_association" "private_sub1_10_2_0_0" {
  route_table_id = aws_route_table.private_10_2_0_0.id
  subnet_id      = aws_subnet.private1_10_2_0_0.id
}

resource "aws_route_table_association" "private_sub2_10_2_0_0" {
  route_table_id = aws_route_table.private_10_2_0_0.id
  subnet_id      = aws_subnet.private2_10_2_0_0.id
}

resource "aws_route_table_association" "private_sub3_10_2_0_0" {
  route_table_id = aws_route_table.private_10_2_0_0.id
  subnet_id      = aws_subnet.private3_10_2_0_0.id
}

resource "aws_eip" "nat_gateway_10_2_0_0" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw_10_2_0_0]
}

resource "aws_nat_gateway" "default_10_2_0_0" {
  allocation_id = aws_eip.nat_gateway_10_2_0_0.id
  subnet_id     = aws_subnet.public1_10_2_0_0.id
}

#### Security Groups

resource "aws_security_group" "allow_egress_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
  name   = "allow_egress"
}

resource "aws_security_group_rule" "allow_egress_10_2_0_0" {
  security_group_id = aws_security_group.allow_egress_10_2_0_0.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "allow_22_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
  name   = "10_2_0_0_allow_22"
}

resource "aws_security_group_rule" "allow_22_10_2_0_0" {
  security_group_id = aws_security_group.allow_22_10_2_0_0.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group" "allow_vpc_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
  name   = "allow_vpc"
}

resource "aws_security_group_rule" "allow_vpc_10_2_0_0" {
  security_group_id = aws_security_group.allow_vpc_10_2_0_0.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc_10_2_0_0.cidr_block]
}

resource "aws_instance" "jumphost_10_2_0_0_jumphost" {
  ami           = data.aws_ami.freebsd_11.image_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.public1_10_2_0_0.id

  vpc_security_group_ids = [
    aws_security_group.allow_22_10_2_0_0.id,
    aws_security_group.allow_vpc_10_2_0_0.id,
    aws_security_group.allow_egress_10_2_0_0.id,
  ]

  key_name = aws_key_pair.default.key_name

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF


  tags = {
    Name = "10_2_0_0_jumphost"
  }
}

resource "aws_vpc_endpoint" "nlb" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  service_name      = aws_vpc_endpoint_service.nlb.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_egress_10_2_0_0.id,
    aws_security_group.allow_vpc_10_2_0_0.id,
  ]

  subnet_ids = [
    aws_subnet.private1_10_2_0_0.id,
    aws_subnet.private2_10_2_0_0.id,
    aws_subnet.private3_10_2_0_0.id,
  ]
}

