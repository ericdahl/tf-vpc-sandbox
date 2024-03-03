provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "ipv6"
    }
  }
}

resource "aws_vpc" "default" {

  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true
}

resource "aws_subnet" "default" {
  vpc_id                                         = aws_vpc.default.id
  availability_zone                              = "us-east-1a"
  ipv6_cidr_block                                = "2600:1f18:28e8:9100::/64"
  ipv6_native                                    = true
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "default" {
  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.default.id
}

data "aws_ssm_parameter" "ecs_amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "default" {

  subnet_id     = aws_subnet.default.id
  ami           = data.aws_ssm_parameter.ecs_amazon_linux_2.value
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.default.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
}

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.default.id

  type     = "ingress"
  protocol = "-1"

  ipv6_cidr_blocks = ["::/0"]

  from_port = 0
  to_port   = 0
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.default.id

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "ingress_ipv4" {
  security_group_id = aws_security_group.default.id

  type     = "ingress"
  protocol = "-1"

  cidr_blocks = ["0.0.0.0/0"]

  from_port = 0
  to_port   = 0
}

resource "aws_security_group_rule" "egress_all_ipv4" {
  security_group_id = aws_security_group.default.id

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]

}