resource "aws_vpc" "vpc_10_1_0_0" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "10.1.0.0/16"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public1_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2_10_1_0_0" {
  vpc_id                  = aws_vpc.vpc_10_1_0_0.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public3_10_1_0_0" {
  vpc_id                  = aws_vpc.vpc_10_1_0_0.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1_10_1_0_0" {
  vpc_id            = aws_vpc.vpc_10_1_0_0.id
  cidr_block        = "10.1.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private2_10_1_0_0" {
  vpc_id            = aws_vpc.vpc_10_1_0_0.id
  cidr_block        = "10.1.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private3_10_1_0_0" {
  vpc_id            = aws_vpc.vpc_10_1_0_0.id
  cidr_block        = "10.1.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "gw_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id
}

resource "aws_route_table" "public_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_10_1_0_0.id
  }
}

resource "aws_route_table" "private_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default_10_1_0_0.id
  }
}

resource "aws_route_table_association" "sub1_10_1_0_0" {
  route_table_id = aws_route_table.public_10_1_0_0.id
  subnet_id      = aws_subnet.public1_10_1_0_0.id
}

resource "aws_route_table_association" "sub2_10_1_0_0" {
  route_table_id = aws_route_table.public_10_1_0_0.id
  subnet_id      = aws_subnet.public2_10_1_0_0.id
}

resource "aws_route_table_association" "sub3_10_1_0_0" {
  route_table_id = aws_route_table.public_10_1_0_0.id
  subnet_id      = aws_subnet.public3_10_1_0_0.id
}

resource "aws_route_table_association" "private_sub1_10_1_0_0" {
  route_table_id = aws_route_table.private_10_1_0_0.id
  subnet_id      = aws_subnet.private1_10_1_0_0.id
}

resource "aws_route_table_association" "private_sub2_10_1_0_0" {
  route_table_id = aws_route_table.private_10_1_0_0.id
  subnet_id      = aws_subnet.private2_10_1_0_0.id
}

resource "aws_route_table_association" "private_sub3_10_1_0_0" {
  route_table_id = aws_route_table.private_10_1_0_0.id
  subnet_id      = aws_subnet.private3_10_1_0_0.id
}

resource "aws_eip" "nat_gateway_10_1_0_0" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw_10_1_0_0]
}

resource "aws_nat_gateway" "default_10_1_0_0" {
  allocation_id = aws_eip.nat_gateway_10_1_0_0.id
  subnet_id     = aws_subnet.public1_10_1_0_0.id
}

#### Security Groups

resource "aws_security_group" "allow_egress_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id
  name   = "allow_egress"
}

resource "aws_security_group_rule" "allow_egress_10_1_0_0" {
  security_group_id = aws_security_group.allow_egress_10_1_0_0.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "allow_22_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id
  name   = "10_1_0_0_allow_22"
}

resource "aws_security_group_rule" "allow_22_10_1_0_0" {
  security_group_id = aws_security_group.allow_22_10_1_0_0.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip_cidr]
}

resource "aws_security_group" "allow_vpc_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id
  name   = "allow_vpc"
}

resource "aws_security_group_rule" "allow_vpc_10_1_0_0" {
  security_group_id = aws_security_group.allow_vpc_10_1_0_0.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc_10_1_0_0.cidr_block]
}

resource "aws_instance" "jumphost_10_1_0_0_jumphost" {
  ami           = data.aws_ami.freebsd_11.image_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.public1_10_1_0_0.id

  vpc_security_group_ids = [
    aws_security_group.allow_22_10_1_0_0.id,
    aws_security_group.allow_vpc_10_1_0_0.id,
    aws_security_group.allow_egress_10_1_0_0.id,
  ]

  key_name = aws_key_pair.default.key_name

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF


  tags = {
    Name = "10_1_0_0_jumphost"
  }
}

resource "aws_lb" "nlb" {
  name               = "private-link-nlb"
  load_balancer_type = "network"

  internal = "true"

  subnets = [
    aws_subnet.private1_10_1_0_0.id,
    aws_subnet.private2_10_1_0_0.id,
    aws_subnet.private3_10_1_0_0.id,
  ]
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

  port     = 80
  protocol = "TCP"
}

resource "aws_lb_target_group_attachment" "nlb" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_instance.jumphost_10_1_0_0_jumphost.id
  port             = 80
}

resource "aws_instance" "webserver_10_1_0_0" {
  ami           = data.aws_ami.freebsd_11.image_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private1_10_1_0_0.id

  vpc_security_group_ids = [
    aws_security_group.allow_22_10_1_0_0.id,
    aws_security_group.allow_vpc_10_1_0_0.id,
    aws_security_group.allow_egress_10_1_0_0.id,
  ]

  key_name = aws_key_pair.default.key_name

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash nginx

echo 'nginx_enable="YES"' >> /etc/rc.conf
service nginx start

chsh -s /usr/local/bin/bash ec2-user
EOF


  tags = {
    Name = "10_1_0_0_webserver"
  }
}

resource "aws_flow_log" "flow_log_10_1_0_0" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc_10_1_0_0.id
}

resource "aws_s3_bucket" "flow_logs" {
  bucket = "10-1-0-01-vpc-flow-log"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {"Service": "delivery.logs.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::10-1-0-01-vpc-flow-log/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {"Service": "delivery.logs.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::10-1-0-01-vpc-flow-log"
        }
    ]
}

EOF

}

resource "aws_vpc_endpoint_service" "nlb" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb.arn]
}

