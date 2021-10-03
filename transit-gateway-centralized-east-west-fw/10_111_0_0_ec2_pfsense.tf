resource "aws_network_interface" "pfsense_10_111_0_0" {
  subnet_id   = aws_subnet.r10_111_0_0_private1.id
  private_ips = ["10.111.101.111"]

  security_groups = [
    aws_security_group.vpc_10_111_0_0_pfsense.id,
  ]

  source_dest_check = false

  tags = {
    Name = "pfsense_10_111_0_0"
  }
}

resource "aws_network_interface" "pfsense_10_111_0_0_admin" {
  subnet_id   = aws_subnet.r10_111_0_0_public1.id
  security_groups = [
    aws_security_group.vpc_10_111_0_0_pfsense_admin.id,
  ]

  tags = {
    Name = "pfsense_10_111_0_0_admin"
  }


}

resource "aws_eip" "pfsense_10_111_0_0_admin" {
  vpc = true
  network_interface = aws_network_interface.pfsense_10_111_0_0_admin.id
}



resource "aws_instance" "vpc_10_111_0_0_pfsense" {
//  ami           = data.aws_ami.pfsense.id
  ami = data.aws_ami.freebsd.id
  instance_type = "m5.large"

  network_interface {
    network_interface_id = aws_network_interface.pfsense_10_111_0_0.id
    device_index         = 0
  }

//  network_interface {
//    network_interface_id = aws_network_interface.pfsense_10_111_0_0_admin.id
//    device_index         = 1
//  }

  key_name = aws_key_pair.default.key_name

//  # demo password; instance is internal to VPC, no access
//  user_data = <<EOF
//password=foobar
//EOF

  user_data = <<EOF
#!/bin/sh
echo 'gateway_enable="YES"' >> /etc/rc.conf
EOF

  tags = {
    Name = "vpc_10_111_0_0_pfsense"
  }
}


resource "aws_security_group" "vpc_10_111_0_0_pfsense" {
  name   = "vpc_10_111_0_0_pfsense"
  vpc_id = aws_vpc.vpc_10_111_0_0.id
}


resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_egress_all" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "allow egress from all to firewall appliance (it can filter for itself)"
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_ingress_all" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "allow ingress from all to firewall appliance (it can filter for itself)"
}

resource "aws_security_group" "vpc_10_111_0_0_pfsense_admin" {
  name   = "vpc_10_111_0_0_pfsense_admin"
  vpc_id = aws_vpc.vpc_10_111_0_0.id
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_admin_egress_all" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense_admin.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_admin_ingress_443" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense_admin.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]

  description = "allow ingress admin cidr for GUI admin access in public subnet"
}

resource "aws_security_group_rule" "vpc_10_111_0_0_pfsense_admin_ingress_22" {
  security_group_id = aws_security_group.vpc_10_111_0_0_pfsense_admin.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]

  description = "allow ingress admin cidr for ssh admin access in public subnet"
}


output "vpc111_pfsense_private_ip" {
  value = aws_instance.vpc_10_111_0_0_pfsense.private_ip
}

