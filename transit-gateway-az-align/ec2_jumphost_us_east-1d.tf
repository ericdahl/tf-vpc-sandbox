
resource "aws_instance" "jumphost_us_east_1d" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3a.nano"
  subnet_id     = module.vpc_b_c_d["10.2.0.0/16"].subnets.public["us-east-1d"].id

  vpc_security_group_ids = [
    aws_security_group.jumphost_us_east_1d.id
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "jumphost_vpc_a_b_c_2"
  }
}



resource "aws_security_group" "jumphost_us_east_1d" {
  vpc_id = module.vpc_b_c_d["10.2.0.0/16"].vpc.id
  name   = "jumphost_us_east_1d"
}

resource "aws_security_group_rule" "jumphost_us_east_1d_egress" {
  security_group_id = aws_security_group.jumphost_us_east_1d.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jumphost_us_east_1d_ingress_ssh_admin" {
  security_group_id = aws_security_group.jumphost_us_east_1d.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group_rule" "jumphost_us_east_1d_ingress_all_rfc1918" {
  security_group_id = aws_security_group.jumphost_us_east_1d.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8"]
}
