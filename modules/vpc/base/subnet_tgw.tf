resource "aws_subnet" "tgw" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(var.availability_zones, local.tgw_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.default.cidr_block}-tgw"
  }
}

resource "aws_route_table" "tgw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-tgw"
  }
}

resource "aws_route_table_association" "tgw" {
  for_each = aws_subnet.tgw

  route_table_id = aws_route_table.tgw.id
  subnet_id      = each.value.id
}
