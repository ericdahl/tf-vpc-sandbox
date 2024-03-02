resource "aws_networkmanager_global_network" "default" {

}

resource "aws_networkmanager_transit_gateway_registration" "default" {
  global_network_id   = aws_networkmanager_global_network.default.id
  transit_gateway_arn = aws_ec2_transit_gateway.default.arn
}