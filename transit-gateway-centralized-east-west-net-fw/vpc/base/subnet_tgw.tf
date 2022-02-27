resource "aws_subnet" "tgw" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.tgw_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.default.cidr_block}-tgw"
  }
}

resource "aws_route_table" "tgw" {
  vpc_id = aws_vpc.default.id
}

## diff from fw vpc
### fw - default to FW / rfc 1918 to TGW
### priv - default to TGW
#resource "aws_route" "tgw_default_tgw" {
#  route_table_id = aws_route_table.tgw.id
#
#  destination_cidr_block = "0.0.0.0/0"
#  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
#}

resource "aws_route_table_association" "tgw" {
  for_each = aws_subnet.tgw

  route_table_id = aws_route_table.tgw.id
  subnet_id      = each.value.id
}