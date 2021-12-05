resource "aws_ec2_transit_gateway" "default" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "transit-gateway-centralized-east-west-fw"
  }
}
