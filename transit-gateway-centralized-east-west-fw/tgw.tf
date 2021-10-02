resource "aws_ec2_transit_gateway" "default" {
  default_route_table_association = "enable" # TODO: false?
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit-gateway-centralized-east-west-fw"
  }
}
