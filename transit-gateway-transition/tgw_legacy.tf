resource "aws_ec2_transit_gateway" "legacy" {
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-legacy"
  }
}
