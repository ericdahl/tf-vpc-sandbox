resource "aws_instance" "r10_2_0_0_jumphost" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t2.small"
  subnet_id     = aws_subnet.r10_2_0_0_public1.id

  vpc_security_group_ids = [
    aws_security_group.r10_2_0_0_allow_22.id,
    aws_security_group.r10_2_0_0_allow_vpc.id,
    aws_security_group.r10_2_0_0_allow_egress.id,
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "10_2_0_0_jumphost"
  }
}

