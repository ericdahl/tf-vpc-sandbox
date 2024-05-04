resource "aws_instance" "client" {

  subnet_id     = aws_subnet.public["us-east-1a"].id
  ami           = data.aws_ssm_parameter.ecs_amazon_linux_2.value
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.client.id]
  key_name               = aws_key_pair.default.key_name

  user_data = <<EOF
#!/bin/bash

# for apachebench
yum install -y httpd-tools
EOF

  tags = {
    Name = "client"
  }

}

resource "aws_security_group" "client" {
  vpc_id = aws_vpc.default.id
  name   = "${local.name}-client"
}

resource "aws_security_group_rule" "client_egress_all" {
  security_group_id = aws_security_group.client.id

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "client_ingress_ssh" {
  security_group_id = aws_security_group.client.id

  type = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = [var.admin_cidr]
  description = "allows ssh from admin_cidr"
}
