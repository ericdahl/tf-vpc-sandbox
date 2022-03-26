resource "aws_instance" "fw" {
  ami           = data.aws_ami.freebsd.id
  instance_type = "t3a.nano"
  subnet_id     = aws_subnet.fw["us-east-1a"].id

  vpc_security_group_ids = [
    aws_security_group.fw.id
  ]

  key_name = aws_key_pair.default.key_name

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

sysrc gateway_enable=YES
sysrc pf_enable=YES

EOF

  tags = {
    Name = "${var.cidr_block}-fw"
  }

  source_dest_check = false
}

resource "aws_security_group" "fw" {
  vpc_id = aws_vpc.default.id
  name   = "fw"
}

resource "aws_security_group_rule" "fw_egress_all" {
  security_group_id = aws_security_group.fw.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "fw_ingress_all" {
  security_group_id = aws_security_group.fw.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
