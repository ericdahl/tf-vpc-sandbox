data "aws_availability_zones" "default" {}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


resource "aws_key_pair" "default" {
  public_key = var.public_key
}

resource "aws_vpc_peering_connection_accepter" "client" {
  vpc_peering_connection_id = var.vpc_peering_connection
  auto_accept = true
}