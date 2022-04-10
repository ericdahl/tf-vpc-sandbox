resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(var.availability_zones, local.public_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${aws_vpc.default.cidr_block}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-public"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}


#resource "aws_route" "igw_public" {
#  for_each = aws_subnet.public
#
#  route_table_id = aws_route_table.igw.id
#
#  destination_cidr_block = each.value.cidr_block
#  instance_id = aws_instance.fw.id
#}

#resource "aws_route_table_association" "igw" {
#  route_table_id = aws_route_table.igw.id
#  gateway_id = aws_internet_gateway.default.id
#}
