resource "aws_instance" "jumphost" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3a.nano"
  subnet_id     = aws_subnet.public["us-east-1a"].id

  vpc_security_group_ids = [
    aws_security_group.jumphost.id
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "${var.cidr_block}-jumphost"
  }
}

resource "aws_security_group" "jumphost" {
  vpc_id = aws_vpc.default.id
  name   = "jumphost_10_10_0_0"
}

resource "aws_security_group_rule" "jumphost_egress" {
  security_group_id = aws_security_group.jumphost.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jumphost_ingress_ssh_admin" {
  security_group_id = aws_security_group.jumphost.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group_rule" "jumphost_ingress_all_rfc1918" {
  security_group_id = aws_security_group.jumphost.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8"]
}