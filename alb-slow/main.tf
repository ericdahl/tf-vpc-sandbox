provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name       = "alb-slow"
      Repository = "https://github.com/ericdahl/tf-vpc-app"
    }
  }
}

data "aws_default_tags" "default" {}

locals {
  name = data.aws_default_tags.default.tags["Name"]
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

data "aws_ssm_parameter" "ecs_amazon_linux_2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.default.id
  name   = "${local.name}-ec2"
}

resource "aws_security_group_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2.id

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
  description = "allows EC2 hosts to make egress calls"
}


resource "aws_security_group_rule" "ec2_ingress_ssh" {
  security_group_id = aws_security_group.ec2.id

  type = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = [var.admin_cidr]
  description = "allows ssh from admin_cidr"
}
