resource "aws_vpc" "r10_3_0_0" {
  cidr_block = "10.3.0.0/16"

  tags = {
    Name = "10.3.0.0/16"
  }
}

resource "aws_subnet" "r10_3_0_0_public1" {
  vpc_id = aws_vpc.r10_3_0_0.id

  cidr_block              = "10.3.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_3_0_0_public2" {
  vpc_id                  = aws_vpc.r10_3_0_0.id
  cidr_block              = "10.3.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_3_0_0_public3" {
  vpc_id                  = aws_vpc.r10_3_0_0.id
  cidr_block              = "10.3.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "r10_3_0_0_private1" {
  vpc_id            = aws_vpc.r10_3_0_0.id
  cidr_block        = "10.3.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "r10_3_0_0_private2" {
  vpc_id            = aws_vpc.r10_3_0_0.id
  cidr_block        = "10.3.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "r10_3_0_0_private3" {
  vpc_id            = aws_vpc.r10_3_0_0.id
  cidr_block        = "10.3.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "r10_3_0_0" {
  vpc_id = aws_vpc.r10_3_0_0.id
}

resource "aws_route_table" "r10_3_0_0_public" {
  vpc_id = aws_vpc.r10_3_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.r10_3_0_0.id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.default.id
  }
}

resource "aws_route_table" "r10_3_0_0_private" {
  vpc_id = aws_vpc.r10_3_0_0.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.r10_3_0_0_default.id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.default.id
  }
}

resource "aws_route_table_association" "r10_3_0_0_sub1" {
  route_table_id = aws_route_table.r10_3_0_0_public.id
  subnet_id      = aws_subnet.r10_3_0_0_public1.id
}

resource "aws_route_table_association" "r10_3_0_0_sub2" {
  route_table_id = aws_route_table.r10_3_0_0_public.id
  subnet_id      = aws_subnet.r10_3_0_0_public2.id
}

resource "aws_route_table_association" "r10_3_0_0_sub3" {
  route_table_id = aws_route_table.r10_3_0_0_public.id
  subnet_id      = aws_subnet.r10_3_0_0_public3.id
}

resource "aws_route_table_association" "r10_3_0_0_private_sub1" {
  route_table_id = aws_route_table.r10_3_0_0_private.id
  subnet_id      = aws_subnet.r10_3_0_0_private1.id
}

resource "aws_route_table_association" "r10_3_0_0_private_sub2" {
  route_table_id = aws_route_table.r10_3_0_0_private.id
  subnet_id      = aws_subnet.r10_3_0_0_private2.id
}

resource "aws_route_table_association" "r10_3_0_0_private_sub3" {
  route_table_id = aws_route_table.r10_3_0_0_private.id
  subnet_id      = aws_subnet.r10_3_0_0_private3.id
}

resource "aws_eip" "r10_3_0_0_nat_gateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.r10_3_0_0]
}

resource "aws_nat_gateway" "r10_3_0_0_default" {
  allocation_id = aws_eip.r10_3_0_0_nat_gateway.id
  subnet_id     = aws_subnet.r10_3_0_0_public1.id
}

#### Security Groups

resource "aws_security_group" "r10_3_0_0_allow_egress" {
  vpc_id = aws_vpc.r10_3_0_0.id
  name   = "allow_egress"
}

resource "aws_security_group_rule" "r10_3_0_0_allow_egress" {
  security_group_id = aws_security_group.r10_3_0_0_allow_egress.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "r10_3_0_0_allow_22" {
  vpc_id = aws_vpc.r10_3_0_0.id
  name   = "10_3_0_0_allow_22"
}

resource "aws_security_group_rule" "r10_3_0_0_allow_22" {
  security_group_id = aws_security_group.r10_3_0_0_allow_22.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group" "r10_3_0_0_allow_vpc" {
  vpc_id = aws_vpc.r10_3_0_0.id
  name   = "allow_vpc"
}

resource "aws_security_group_rule" "r10_3_0_0_allow_vpc" {
  security_group_id = aws_security_group.r10_3_0_0_allow_vpc.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.r10_3_0_0.cidr_block]
}

resource "aws_security_group_rule" "r10_3_0_0_allow_vpc_peer" {
  security_group_id = aws_security_group.r10_3_0_0_allow_vpc.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "r10_3_0_0" {
  vpc_id             = aws_vpc.r10_3_0_0.id
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  subnet_ids = [
    aws_subnet.r10_3_0_0_private1.id,
    aws_subnet.r10_3_0_0_private2.id,
    aws_subnet.r10_3_0_0_private3.id,
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "10.3.0.0/16"
  }
}

resource "aws_instance" "r10_3_0_0_jumphost" {
  ami           = data.aws_ami.freebsd_11.image_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.r10_3_0_0_public1.id

  vpc_security_group_ids = [
    aws_security_group.r10_3_0_0_allow_22.id,
    aws_security_group.r10_3_0_0_allow_vpc.id,
    aws_security_group.r10_3_0_0_allow_egress.id,
  ]

  key_name = var.key_name

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF


  tags = {
    Name = "10_3_0_0_jumphost"
  }
}

