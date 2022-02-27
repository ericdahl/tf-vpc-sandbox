resource "aws_subnet" "private" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.private_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.default.cidr_block}-private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
}

## diff from fw vpc
### fw - default to NAT / rfc 1918 to TGW
### priv - default to TGW
#resource "aws_route" "private_default_tgw" {
#  route_table_id = aws_route_table.private.id
#
#  destination_cidr_block = "0.0.0.0/0"
#  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
#}


resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}