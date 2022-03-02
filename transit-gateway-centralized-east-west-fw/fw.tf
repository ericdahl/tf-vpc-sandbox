resource "aws_network_interface" "fw" {
  subnet_id   = module.vpc_fw.subnets.private["us-east-1a"].id

  security_groups = [
    aws_security_group.fw.id,
  ]

  source_dest_check = false

  tags = {
    Name = "fw"
  }
}

resource "aws_network_interface" "fw_admin" {
  subnet_id   = module.vpc_fw.subnets.public["us-east-1a"].id
  security_groups = [
    aws_security_group.fw_admin.id,
  ]

  tags = {
    Name = "fw-admin"
  }
}

resource "aws_eip" "fw_admin" {
  vpc = true
  network_interface = aws_network_interface.fw_admin.id
}



resource "aws_instance" "fw" {
  //  ami           = data.aws_ami.fw.id
  ami = data.aws_ami.freebsd.id
  instance_type = "m5.large"

  network_interface {
    network_interface_id = aws_network_interface.fw.id
    device_index         = 0
  }

  //  network_interface {
  //    network_interface_id = aws_network_interface.fw_10_111_0_0_admin.id
  //    device_index         = 1
  //  }

  key_name = aws_key_pair.default.key_name

  //  # demo password; instance is internal to VPC, no access
  //  user_data = <<EOF
  //password=foobar
  //EOF

  user_data = <<EOF
#!/bin/sh

# add some firewall rules
cat << PF_END > /etc/pf.conf
dev_vpc_cidrs = "{ 10.1.0.0/16, 10.2.0.0/16, 10.3.0.0/16 }"

block in all
pass out all keep state

pass in inet proto tcp to any port 22
pass inet proto icmp from any to any

pass inet proto tcp to any port 443 keep state
PF_END

echo 'gateway_enable="YES"' >> /etc/rc.conf
echo 'pf_enable="YES"' >> /etc/rc.conf

EOF

  tags = {
    Name = "fw"
  }
}


resource "aws_security_group" "fw" {
  name   = "fw"
  vpc_id = module.vpc_fw.vpc.id
}


resource "aws_security_group_rule" "fw_egress_all" {
  security_group_id = aws_security_group.fw.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "allow egress from all to firewall appliance (it can filter for itself)"
}

resource "aws_security_group_rule" "fw_ingress_all" {
  security_group_id = aws_security_group.fw.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "allow ingress from all to firewall appliance (it can filter for itself)"
}

resource "aws_security_group" "fw_admin" {
  name   = "fw-admin"
  vpc_id = module.vpc_fw.vpc.id
}

resource "aws_security_group_rule" "fw_admin_egress_all" {
  security_group_id = aws_security_group.fw_admin.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "fw_admin_ingress_443" {
  security_group_id = aws_security_group.fw_admin.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]

  description = "allow ingress admin cidr for GUI admin access in public subnet"
}

resource "aws_security_group_rule" "fw_admin_ingress_22" {
  security_group_id = aws_security_group.fw_admin.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]

  description = "allow ingress admin cidr for ssh admin access in public subnet"
}


