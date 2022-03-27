resource "aws_instance" "fw" {
  ami           = data.aws_ami.pfsense.id
  instance_type = "m4.large"
#  subnet_id     = aws_subnet.fw["us-east-1a"].id

#  vpc_security_group_ids = [
#    aws_security_group.fw.id
#  ]

  key_name = aws_key_pair.default.key_name


  tags = {
    Name = "${var.cidr_block}-fw"
  }

#  source_dest_check = false

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fw_wan.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.fw_lan.id

  }

}


resource "aws_network_interface" "fw_wan" {
  subnet_id = aws_subnet.public["us-east-1a"].id

  security_groups = [aws_security_group.fw_wan.id]
}

resource "aws_network_interface" "fw_lan" {
  subnet_id = aws_subnet.fw["us-east-1a"].id
  
  security_groups = [aws_security_group.fw_lan.id]

  source_dest_check = false
}

resource "aws_eip" "fw_wan" {
  vpc = true
}

resource "aws_eip_association" "fw_wan" {
  allocation_id = aws_eip.fw_wan.allocation_id
  network_interface_id = aws_network_interface.fw_wan.id
}

resource "aws_security_group" "fw_wan" {
  vpc_id = aws_vpc.default.id
  name   = "fw"
}

resource "aws_security_group_rule" "fw_egress_all" {
  security_group_id = aws_security_group.fw_wan.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "fw_ingress_lan" {
  security_group_id = aws_security_group.fw_wan.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.admin_ip_cidr]
}



resource "aws_security_group" "fw_lan" {
  vpc_id = aws_vpc.default.id
  name   = "fw_lan"
}

resource "aws_security_group_rule" "fw_lan_egress_all" {
  security_group_id = aws_security_group.fw_lan.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "fw_lan_ingress_all" {
  security_group_id = aws_security_group.fw_lan.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}