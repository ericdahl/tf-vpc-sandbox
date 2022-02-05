resource "aws_vpc" "server" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "default" {}


resource "aws_subnet" "server_public" {
  vpc_id = aws_vpc.server.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), cidrsubnets(aws_vpc.server.cidr_block, 8, 8, 8))

  availability_zone = each.key


  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "server-public"
  }
}

resource "aws_internet_gateway" "server" {
  vpc_id = aws_vpc.server.id
}

resource "aws_route_table" "server_public" {
  vpc_id = aws_vpc.server.id
}

resource "aws_route" "server_public" {
  route_table_id = aws_route_table.server_public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.server.id
}

resource "aws_route_table_association" "server_public" {
  for_each = aws_subnet.server_public

  route_table_id = aws_route_table.server_public.id
  subnet_id      = each.value.id
}


