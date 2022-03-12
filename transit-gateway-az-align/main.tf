provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-az-align"
    }
  }
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

module "vpc_a_b_c" {
  source = "../modules/vpc/workload"

  for_each = toset([
    "10.1.0.0/16",
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  tgw_default_route_association = true
}

module "vpc_b_c_d" {
  source = "../modules/vpc/workload"

  for_each = toset([
    "10.2.0.0/16",
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.default.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  availability_zones = ["us-east-1b", "us-east-1c", "us-east-1d"]
  ec2_internal_az = "us-east-1b"
  ec2_jumphost_az = "us-east-1b"

  tgw_default_route_association = true
}

resource "aws_instance" "jumphost_vpc_a_b_c_2" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3a.nano"
  subnet_id     = module.vpc_a_b_c["10.1.0.0/16"].subnets.public["us-east-1b"].id

  vpc_security_group_ids = [
    aws_security_group.jumphost.id
  ]

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "jumphost_vpc_a_b_c_2"
  }
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


resource "aws_security_group" "jumphost" {
  vpc_id = module.vpc_a_b_c["10.1.0.0/16"].vpc.id
  name   = "jumphost"
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
