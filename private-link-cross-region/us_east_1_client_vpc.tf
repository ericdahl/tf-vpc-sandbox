resource "aws_vpc" "client" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "client"
  }
}

resource "aws_subnet" "client_public" {
  vpc_id = aws_vpc.client.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), cidrsubnets(aws_vpc.client.cidr_block, 8, 8, 8))

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "client-public"
  }
}

resource "aws_internet_gateway" "client" {
  vpc_id = aws_vpc.client.id
}

resource "aws_route_table" "client_public" {
  vpc_id = aws_vpc.client.id
}


resource "aws_route" "client_vpc_peer" {
  route_table_id = aws_route_table.client_public.id

  destination_cidr_block = aws_vpc.ap_southeast_1_client.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.client.id
}

resource "aws_route" "client_public" {
  route_table_id = aws_route_table.client_public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.client.id
}

resource "aws_route_table_association" "client_public" {
  for_each = aws_subnet.client_public

  route_table_id = aws_route_table.client_public.id
  subnet_id      = each.value.id
}


