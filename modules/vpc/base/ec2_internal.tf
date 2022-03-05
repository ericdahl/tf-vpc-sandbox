resource "aws_instance" "internal" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3a.nano"
  subnet_id     = aws_subnet.private["us-east-1a"].id

  vpc_security_group_ids = [
    aws_security_group.internal.id
  ]

  key_name = aws_key_pair.default.key_name

  user_data = <<EOF
#cloud-config
packages:
  - nc
EOF

  tags = {
    Name = "${var.cidr_block}-internal"
  }
}

resource "aws_security_group" "internal" {
  vpc_id = aws_vpc.default.id
  name   = "internal_10_10_0_0"
}

resource "aws_security_group_rule" "internal_egress" {
  security_group_id = aws_security_group.internal.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "internal_ingress_all_rfc1918" {
  security_group_id = aws_security_group.internal.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8"]
}
