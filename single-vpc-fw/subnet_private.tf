resource "aws_subnet" "private" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(var.availability_zones, local.private_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.default.cidr_block}-private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

resource "aws_route" "private_default_fw" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  network_interface_id = aws_instance.fw.primary_network_interface_id
}