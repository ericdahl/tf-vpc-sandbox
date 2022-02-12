resource "aws_vpc" "ap_southeast_1_client" {
  provider = aws.aws_ap_southeast-1

  cidr_block = "10.200.0.0/16"
}

resource "aws_subnet" "ap_southeast_1_client_public" {
  provider = aws.aws_ap_southeast-1

  vpc_id = aws_vpc.ap_southeast_1_client.id

  for_each = zipmap(slice(data.aws_availability_zones.ap_southeast_1_default.names, 0, 3), cidrsubnets(aws_vpc.ap_southeast_1_client.cidr_block, 8, 8, 8))

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "ap-southeast-1-client-public"
  }
}

resource "aws_internet_gateway" "ap_southeast_1_client" {
  provider = aws.aws_ap_southeast-1

  vpc_id = aws_vpc.ap_southeast_1_client.id
}

resource "aws_route_table" "ap_southeast_1_client_public" {
  provider = aws.aws_ap_southeast-1

  vpc_id = aws_vpc.ap_southeast_1_client.id
}

resource "aws_route" "ap_southeast_1_client_vpc_peer" {
  provider = aws.aws_ap_southeast-1
  route_table_id = aws_route_table.ap_southeast_1_client_public.id

  destination_cidr_block = aws_vpc.client.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.client.id
}

resource "aws_route" "ap_southeast_1_client_public" {
  provider = aws.aws_ap_southeast-1

  route_table_id = aws_route_table.ap_southeast_1_client_public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ap_southeast_1_client.id
}

resource "aws_route_table_association" "ap_southeast_1_client_public" {
  provider = aws.aws_ap_southeast-1

  for_each = aws_subnet.ap_southeast_1_client_public

  route_table_id = aws_route_table.ap_southeast_1_client_public.id
  subnet_id      = each.value.id
}


