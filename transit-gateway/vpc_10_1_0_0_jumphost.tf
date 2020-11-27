
resource "aws_instance" "vpc_10_1_0_0_jumphost" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t2.small"
  subnet_id     = aws_subnet.vpc_10_1_0_0_public1.id

  vpc_security_group_ids = [
    aws_security_group.vpc_10_1_0_0_jumphost.id,
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "10_1_0_0_jumphost"
  }
}


resource "aws_security_group" "vpc_10_1_0_0_jumphost" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id
  name   = "10_1_0_0_jumphost"
}

resource "aws_security_group_rule" "vpc_10_1_0_0_jumphost_egress" {
  security_group_id = aws_security_group.vpc_10_1_0_0_jumphost.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc_10_1_0_0_jumphost_ssh" {
  security_group_id = aws_security_group.vpc_10_1_0_0_jumphost.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.admin_cidrs
}

resource "aws_security_group_rule" "vpc_10_1_0_0_jumphost_vpc" {
  security_group_id = aws_security_group.vpc_10_1_0_0_jumphost.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    aws_vpc.vpc_10_1_0_0.cidr_block,
    aws_vpc.vpc_10_2_0_0.cidr_block
  ]
}