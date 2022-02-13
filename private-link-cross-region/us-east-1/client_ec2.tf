resource "aws_instance" "client" {
  instance_type          = "t3.small"
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
  subnet_id              = aws_subnet.client_public["us-east-1a"].id
  vpc_security_group_ids = [aws_security_group.client.id]
  key_name               = aws_key_pair.default.key_name
}

resource "aws_security_group" "client" {
  vpc_id = aws_vpc.client.id
}

resource "aws_security_group_rule" "client_egress_all" {
  security_group_id = aws_security_group.client.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "client_ingress_icmp_vpc" {
  security_group_id = aws_security_group.client.id

  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = [
    aws_vpc.client.cidr_block,
    var.peer_cidr_block
  ]
}

resource "aws_security_group_rule" "client_ingress_ssh_admin" {
  security_group_id = aws_security_group.client.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.admin_cidrs
}

output "client" {
  value = aws_instance.client.public_ip
}

