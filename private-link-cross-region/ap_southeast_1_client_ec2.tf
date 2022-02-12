resource "aws_instance" "ap_southeast_1_client" {
  provider = aws.aws_ap_southeast-1
  
  instance_type          = "t3.small"
  ami                    = data.aws_ssm_parameter.ap_southeast_1_amazon_linux_2.value
  subnet_id              = aws_subnet.ap_southeast_1_client_public["ap-southeast-1a"].id
  vpc_security_group_ids = [aws_security_group.ap_southeast_1_client.id]
  key_name               = aws_key_pair.ap_southeast_1_default.key_name
}

resource "aws_security_group" "ap_southeast_1_client" {
  provider = aws.aws_ap_southeast-1
  
  vpc_id = aws_vpc.ap_southeast_1_client.id
}

resource "aws_security_group_rule" "ap_southeast_1_client_egress_all" {
  provider = aws.aws_ap_southeast-1
  
  security_group_id = aws_security_group.ap_southeast_1_client.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ap_southeast_1_client_ingress_ssh_admin" {
  provider = aws.aws_ap_southeast-1
  
  security_group_id = aws_security_group.ap_southeast_1_client.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.admin_cidrs
}

resource "aws_security_group_rule" "ap_southeast_1_client_ingress_icmp_vpc" {
  provider = aws.aws_ap_southeast-1

  security_group_id = aws_security_group.ap_southeast_1_client.id

  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = [
    aws_vpc.client.cidr_block,
    aws_vpc.ap_southeast_1_client.cidr_block
  ]
}

output "ap_southeast_1_client" {
  value = aws_instance.ap_southeast_1_client.public_ip
}

