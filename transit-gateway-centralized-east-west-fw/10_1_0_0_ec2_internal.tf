

resource "aws_security_group" "internal_10_1_0_0" {
  vpc_id = aws_vpc.r10_1_0_0.id
  name   = "internal_10_1_0_0"
}

resource "aws_security_group_rule" "internal_10_1_0_0_egress" {
  security_group_id = aws_security_group.internal_10_1_0_0.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "internal_10_1_0_0_ingress" {
  security_group_id = aws_security_group.internal_10_1_0_0.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.r10_1_0_0.cidr_block]
}

resource "aws_instance" "r10_1_0_0_internal" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t2.small"
  subnet_id     = aws_subnet.r10_1_0_0_private1.id

  vpc_security_group_ids = [
    aws_security_group.internal_10_1_0_0.id
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "10_1_0_0_internal"
  }
}

output "r10_1_0_0_internal_private_ip" {
  value = aws_instance.r10_1_0_0_internal.private_ip
}