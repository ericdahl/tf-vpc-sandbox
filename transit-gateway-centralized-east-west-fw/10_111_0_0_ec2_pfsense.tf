data "aws_ami" "pfsense" {
  owners = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "product-code"
    values = ["cphb99lr7icr3n9x6kc3102s5"]
  }

  filter {
    name   = "name"
    values = ["pfSense-plus-ec2-21.05.1-RELEASE-amd64*"]
  }
}

resource "aws_network_interface" "pfsense_10_111_0_0" {
  subnet_id = aws_subnet.r10_111_0_0_private1.id
  private_ips = ["10.111.101.111"]
  tags = {
    Name = "pfsense_10_111_0_0"
  }

  security_groups = [
    aws_security_group.vpc_10_111_0_0_pfsense.id,
  ]

  source_dest_check = false
}

resource "aws_instance" "vpc_10_111_0_0_pfsense" {
  ami           = data.aws_ami.pfsense.id
  instance_type = "m4.large"

  network_interface {
    network_interface_id = aws_network_interface.pfsense_10_111_0_0.id
    device_index         = 0
  }

  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "vpc_10_111_0_0_pfsense"
  }
}


resource "aws_security_group" "vpc_10_111_0_0_pfsense" {
  name   = "vpc_10_111_0_0_pfsense"
  vpc_id = aws_vpc.vpc_10_111_0_0.id
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_icmp" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_jumphost" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  source_security_group_id = aws_security_group.jumphost_10_111_0_0.id
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_egress_all" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

//
//resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_22" {
//  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
//  type              = "ingress"
//  from_port         = 22
//  to_port           = 22
//  protocol          = "tcp"
//  cidr_blocks       = [var.admin_cidr]
//}
//
//resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_443" {
//  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
//  type              = "ingress"
//  from_port         = 443
//  to_port           = 443
//  protocol          = "tcp"
//  cidr_blocks       = var.admin_cidrs
//}
//
//resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_500" {
//  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
//  type              = "ingress"
//  from_port         = 500
//  to_port           = 500
//  protocol          = "udp"
//  cidr_blocks       = ["${aws_instance.vpc_10_222_0_0_pfsense.public_ip}/32"]
//}
//
//resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_4500" {
//  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
//  type              = "ingress"
//  from_port         = 4500
//  to_port           = 4500
//  protocol          = "udp"
//  cidr_blocks       = ["${aws_instance.vpc_10_222_0_0_pfsense.public_ip}/32"]
//}

output "vpc111_pfsense_private_ip" {
  value = aws_instance.vpc_10_111_0_0_pfsense.private_ip
}

