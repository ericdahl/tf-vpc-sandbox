resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-igw"
  }
}

resource "aws_route" "igw_default" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.igw.id

  destination_cidr_block = each.value.cidr_block
  network_interface_id = aws_instance.fw.primary_network_interface_id
}