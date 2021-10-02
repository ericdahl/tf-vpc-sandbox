resource "aws_security_group" "jumphost_10_1_0_0" {
  vpc_id = aws_vpc.r10_1_0_0.id
  name   = "jumphost_10_1_0_0"
}

resource "aws_security_group_rule" "jumphost_10_1_0_0_egress" {
  security_group_id = aws_security_group.jumphost_10_1_0_0.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jumphost_10_1_0_0_ingress" {
  security_group_id = aws_security_group.jumphost_10_1_0_0.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group_rule" "jumphost_10_1_0_0_ingress_rfc" {
  security_group_id = aws_security_group.jumphost_10_1_0_0.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8"]
}

resource "aws_instance" "r10_1_0_0_jumphost" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t2.small"
  subnet_id     = aws_subnet.r10_1_0_0_public1.id

  vpc_security_group_ids = [
    aws_security_group.jumphost_10_1_0_0.id
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "10_1_0_0_jumphost"
  }
}

output "vpc1_jumphost_public_ip" {
  value = aws_instance.r10_1_0_0_jumphost.public_ip
}

output "vpc1_jumphost_private_ip" {
  value = aws_instance.r10_1_0_0_jumphost.private_ip
}

