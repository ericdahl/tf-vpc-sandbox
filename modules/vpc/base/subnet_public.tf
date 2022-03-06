resource "aws_subnet" "public" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), local.public_subnet_cidrs)

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

resource "aws_route" "public_rfc_1918_tgw" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  route_table_id = aws_route_table.public.id

  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.default.transit_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}