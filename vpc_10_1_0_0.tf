resource "aws_vpc" "10_1_0_0" {
  cidr_block = "10.1.0.0/16"

  tags {
    Name = "10.1.0.0/16"
  }
}

resource "aws_subnet" "10_1_0_0_public1" {
  vpc_id                  = "${aws_vpc.10_1_0_0.id}"

  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "10_1_0_0_public2" {
  vpc_id                  = "${aws_vpc.10_1_0_0.id}"
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "10_1_0_0_public3" {
  vpc_id                  = "${aws_vpc.10_1_0_0.id}"
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "10_1_0_0_private1" {
  vpc_id            = "${aws_vpc.10_1_0_0.id}"
  cidr_block        = "10.1.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "10_1_0_0_private2" {
  vpc_id            = "${aws_vpc.10_1_0_0.id}"
  cidr_block        = "10.1.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "10_1_0_0_private3" {
  vpc_id            = "${aws_vpc.10_1_0_0.id}"
  cidr_block        = "10.1.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "10_1_0_0" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"
}

resource "aws_route_table" "10_1_0_0_public" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.10_1_0_0.id}"
  }
}

resource "aws_route_table" "10_1_0_0_private" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.10_1_0_0_default.id}"
  }
}

resource "aws_route_table_association" "10_1_0_0_sub1" {
  route_table_id = "${aws_route_table.10_1_0_0_public.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_public1.id}"
}

resource "aws_route_table_association" "10_1_0_0_sub2" {
  route_table_id = "${aws_route_table.10_1_0_0_public.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_public2.id}"
}

resource "aws_route_table_association" "10_1_0_0_sub3" {
  route_table_id = "${aws_route_table.10_1_0_0_public.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_public3.id}"
}

resource "aws_route_table_association" "10_1_0_0_private_sub1" {
  route_table_id = "${aws_route_table.10_1_0_0_private.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_private1.id}"
}

resource "aws_route_table_association" "10_1_0_0_private_sub2" {
  route_table_id = "${aws_route_table.10_1_0_0_private.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_private2.id}"
}

resource "aws_route_table_association" "10_1_0_0_private_sub3" {
  route_table_id = "${aws_route_table.10_1_0_0_private.id}"
  subnet_id      = "${aws_subnet.10_1_0_0_private3.id}"
}

resource "aws_eip" "10_1_0_0_nat_gateway" {
  vpc        = true
  depends_on = ["aws_internet_gateway.10_1_0_0"]
}

resource "aws_nat_gateway" "10_1_0_0_default" {
  allocation_id = "${aws_eip.10_1_0_0_nat_gateway.id}"
  subnet_id     = "${aws_subnet.10_1_0_0_public1.id}"
}

#### Security Groups

resource "aws_security_group" "10_1_0_0_allow_egress" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"
  name   = "allow_egress"
}

resource "aws_security_group_rule" "10_1_0_0_allow_egress" {
  security_group_id = "${aws_security_group.10_1_0_0_allow_egress.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "10_1_0_0_allow_22" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"
  name   = "10_1_0_0_allow_22"
}

resource "aws_security_group_rule" "10_1_0_0_allow_22" {
  security_group_id = "${aws_security_group.10_1_0_0_allow_22.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.admin_ip_cidr}"]
}

resource "aws_security_group" "10_1_0_0_allow_vpc" {
  vpc_id = "${aws_vpc.10_1_0_0.id}"
  name   = "allow_vpc"
}

resource "aws_security_group_rule" "10_1_0_0_allow_vpc" {
  security_group_id = "${aws_security_group.10_1_0_0_allow_vpc.id}"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${aws_vpc.10_1_0_0.cidr_block}"]
}

