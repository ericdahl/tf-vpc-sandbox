locals {
  public_subnet_cidrs = [ for s in range(0, 3) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]
  private_subnet_cidrs = [ for s in range(128, 131) : cidrsubnet(aws_vpc.default.cidr_block, 8, s)]

  #  subnet_cidrs = cidrsubnets("10.0.128.0/16", [ for i in range(256): 8 ]...)
  #  public_subnet_cidrs = slice(local.subnet_cidrs, 0, 3)
  #  private_subnet_cidrs = slice(local.subnet_cidrs, length(local.subnet_cidrs) / 2, length(local.subnet_cidrs) / 2 + 3)

}


data "aws_availability_zones" "default" {}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.cidr_block
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.public_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cidr_block}-public"
  }
}


resource "aws_subnet" "private" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.private_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cidr_block}-private"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route" "public_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.public.id

  destination_cidr_block = each.value
  transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "private_default_tgw" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
}


resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}



##
##resource "aws_subnet" "r10_10_0_0_public1" {
##  vpc_id = aws_vpc.r10_10_0_0.id
##
##  cidr_block              = "10.10.1.0/24"
##  availability_zone       = "us-east-1a"
##  map_public_ip_on_launch = true
##}
##
##resource "aws_subnet" "r10_10_0_0_public2" {
##  vpc_id                  = aws_vpc.r10_10_0_0.id
##  cidr_block              = "10.10.2.0/24"
##  availability_zone       = "us-east-1b"
##  map_public_ip_on_launch = true
##}
#
##resource "aws_subnet" "r10_10_0_0_public3" {
##  vpc_id                  = aws_vpc.r10_10_0_0.id
##  cidr_block              = "10.10.3.0/24"
##  availability_zone       = "us-east-1c"
##  map_public_ip_on_launch = true
##}
#
#resource "aws_subnet" "r10_10_0_0_private1" {
#  vpc_id            = aws_vpc.r10_10_0_0.id
#  cidr_block        = "10.10.101.0/24"
#  availability_zone = "us-east-1a"
#}
#
#resource "aws_subnet" "r10_10_0_0_private2" {
#  vpc_id            = aws_vpc.r10_10_0_0.id
#  cidr_block        = "10.10.102.0/24"
#  availability_zone = "us-east-1b"
#}
#
#resource "aws_subnet" "r10_10_0_0_private3" {
#  vpc_id            = aws_vpc.r10_10_0_0.id
#  cidr_block        = "10.10.103.0/24"
#  availability_zone = "us-east-1c"
#}
#
#resource "aws_internet_gateway" "r10_10_0_0" {
#  vpc_id = aws_vpc.r10_10_0_0.id
#}
#
#resource "aws_route_table" "r10_10_0_0_public" {
#  vpc_id = aws_vpc.r10_10_0_0.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.r10_10_0_0.id
#  }
#
#  route {
#    cidr_block         = "10.0.0.0/8"
#    transit_gateway_id = aws_ec2_transit_gateway.default.id
#  }
#
#  tags = {
#    Name = "r10_10_0_0_public"
#  }
#}
#
#resource "aws_route_table" "r10_10_0_0_private" {
#  vpc_id = aws_vpc.r10_10_0_0.id
#
#  route {
#    cidr_block         = "0.0.0.0/0"
#    transit_gateway_id = aws_ec2_transit_gateway.default.id
#  }
#
#  tags = {
#    Name = "r10_10_0_0_private"
#  }
#}
#
#resource "aws_route_table_association" "r10_10_0_0_sub1" {
#  route_table_id = aws_route_table.r10_10_0_0_public.id
#  subnet_id      = aws_subnet.r10_10_0_0_public1.id
#}
#
#resource "aws_route_table_association" "r10_10_0_0_sub2" {
#  route_table_id = aws_route_table.r10_10_0_0_public.id
#  subnet_id      = aws_subnet.r10_10_0_0_public2.id
#}
#
#resource "aws_route_table_association" "r10_10_0_0_sub3" {
#  route_table_id = aws_route_table.r10_10_0_0_public.id
#  subnet_id      = aws_subnet.r10_10_0_0_public3.id
#}
#
#resource "aws_route_table_association" "r10_10_0_0_private_sub1" {
#  route_table_id = aws_route_table.r10_10_0_0_private.id
#  subnet_id      = aws_subnet.r10_10_0_0_private1.id
#}
#
#resource "aws_route_table_association" "r10_10_0_0_private_sub2" {
#  route_table_id = aws_route_table.r10_10_0_0_private.id
#  subnet_id      = aws_subnet.r10_10_0_0_private2.id
#}
#
#resource "aws_route_table_association" "r10_10_0_0_private_sub3" {
#  route_table_id = aws_route_table.r10_10_0_0_private.id
#  subnet_id      = aws_subnet.r10_10_0_0_private3.id
#}
#
#resource "aws_ec2_transit_gateway_vpc_attachment" "r10_10_0_0" {
#  vpc_id             = aws_vpc.r10_10_0_0.id
#  transit_gateway_id = aws_ec2_transit_gateway.default.id
#
#  subnet_ids = [
#    aws_subnet.r10_10_0_0_private1.id,
#    aws_subnet.r10_10_0_0_private2.id,
#    aws_subnet.r10_10_0_0_private3.id,
#  ]
#
#  transit_gateway_default_route_table_association = false
#  transit_gateway_default_route_table_propagation = false
#
#  tags = {
#    Name = "10.10.0.0/16"
#  }
#}
#
#
#resource "aws_flow_log" "r10_10_0_0" {
#  vpc_id          = aws_vpc.r10_10_0_0.id
#  traffic_type    = "ALL"
#  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
#  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
#}

#resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
#  for_each = toset([var.tgw_id])
#
#  vpc_id             = aws_vpc.default.id
#  transit_gateway_id = each.value

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  vpc_id             = aws_vpc.default.id
  transit_gateway_id = var.tgw_id

  subnet_ids = [ for s in aws_subnet.private : s.id ]


  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = var.cidr_block
  }
}