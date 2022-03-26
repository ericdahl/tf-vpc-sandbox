resource "aws_subnet" "fw" {
  vpc_id = aws_vpc.default.id

  for_each = zipmap(var.availability_zones, local.fw_subnet_cidrs)

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${aws_vpc.default.cidr_block}-fw"
  }
}

resource "aws_route_table" "fw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${aws_vpc.default.cidr_block}-fw"
  }
}

resource "aws_route_table_association" "fw" {
  for_each = aws_subnet.fw

  route_table_id = aws_route_table.fw.id
  subnet_id      = each.value.id
}

resource "aws_route" "fw_default_nat_gw" {
  route_table_id = aws_route_table.fw.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.default.id
  service_name = "com.amazonaws.us-east-1.s3"

  route_table_ids = [
    aws_route_table.fw.id
  ]
}