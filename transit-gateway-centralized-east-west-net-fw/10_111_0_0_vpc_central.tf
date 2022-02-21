locals {
  public_subnet_cidrs  = [for s in range(0, 3) : cidrsubnet(aws_vpc.fw.cidr_block, 8, s)]
  private_subnet_cidrs = [for s in range(128, 131) : cidrsubnet(aws_vpc.fw.cidr_block, 8, s)]
  private_tgw_subnet_cidrs = [for s in range(132, 135) : cidrsubnet(aws_vpc.fw.cidr_block, 8, s)]
}

data "aws_availability_zones" "default" {}

resource "aws_vpc" "fw" {
  cidr_block = "10.111.0.0/16"

  tags = {
    Name = "10.111.0.0/16"
  }
}

#### PUBLIC

resource "aws_subnet" "fw_public" {
  vpc_id = aws_vpc.fw.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.public_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${aws_vpc.fw.cidr_block}-public"
  }
}

resource "aws_route_table" "fw_public" {
  vpc_id = aws_vpc.fw.id
}

resource "aws_route" "fw_public" {
  route_table_id = aws_route_table.fw_public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fw.id
}

resource "aws_route" "fw_public_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.fw_public.id

  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.fw.transit_gateway_id
}

resource "aws_route_table_association" "fw_public" {
  for_each = aws_subnet.fw_public

  route_table_id = aws_route_table.fw_public.id
  subnet_id      = each.value.id
}



#### PRIVATE


resource "aws_subnet" "fw_private" {
  vpc_id = aws_vpc.fw.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.private_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.fw.cidr_block}-private"
  }
}


resource "aws_route_table" "fw_private" {
  vpc_id = aws_vpc.fw.id

  tags = {
    Name = "r10_111_0_0_private"
  }
}


resource "aws_route" "fw_private_nat_gw" {
  route_table_id = aws_route_table.fw_private.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.r10_111_0_0_default.id
}

resource "aws_route" "fw_private_rfc_1918" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.fw_private.id

  destination_cidr_block         = each.value
  transit_gateway_id = aws_ec2_transit_gateway.default.id
  //    network_interface_id = aws_network_interface.pfsense_10_111_0_0.id
}


resource "aws_route_table_association" "fw_private" {
  for_each = aws_subnet.fw_private

  route_table_id = aws_route_table.fw_private.id
  subnet_id      = each.value.id
}



#### TGW



resource "aws_subnet" "fw_private_tgw" {
  vpc_id = aws_vpc.fw.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.private_tgw_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.fw.cidr_block}-private-tgw"
  }
}

resource "aws_route_table" "fw_private_tgw" {
  vpc_id = aws_vpc.fw.id

  tags = {
    Name = "r10_111_0_0_private_tgw"
  }
}

resource "aws_route" "fw_private_tgw_firewall" {
  route_table_id = aws_route_table.fw_private_tgw.id

  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = tolist(aws_networkfirewall_firewall.default.firewall_status[0].sync_states)[0].attachment[0].endpoint_id

  # workaround for https://github.com/hashicorp/terraform-provider-aws/issues/1426
  # without this, the Plan reports that current route has (instance_id, eni_id) and forces
  # recreate to (eni_id). We only route to eni_id
#  lifecycle {
#    ignore_changes = [route]
#  }
}

resource "aws_route" "fw_private_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.fw_private.id

  destination_cidr_block         = each.value
  transit_gateway_id = aws_ec2_transit_gateway.default.id
  //    network_interface_id = aws_network_interface.pfsense_10_111_0_0.id
}

resource "aws_route_table_association" "fw_private_tgw" {
  for_each = aws_subnet.fw_private_tgw

  route_table_id = aws_route_table.fw_private_tgw.id
  subnet_id      = each.value.id
}


resource "aws_internet_gateway" "fw" {
  vpc_id = aws_vpc.fw.id
}

resource "aws_eip" "r10_111_0_0_nat_gateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.fw]
}

resource "aws_nat_gateway" "r10_111_0_0_default" {
  allocation_id = aws_eip.r10_111_0_0_nat_gateway.id
  subnet_id     = aws_subnet.fw_public["us-east-1a"].id
}


resource "aws_ec2_transit_gateway_vpc_attachment" "fw" {
  vpc_id             = aws_vpc.fw.id
  transit_gateway_id = aws_ec2_transit_gateway.default.id

  subnet_ids = [ for s in aws_subnet.fw_private_tgw : s.id ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = "10.111.0.0/16"
  }
}


resource "aws_flow_log" "r10_111_0_0" {
  vpc_id          = aws_vpc.fw.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
}





