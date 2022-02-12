provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

provider "aws" {
  alias = "aws_ap_southeast-1"
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "ap_southeast_1_amazon_linux_2" {
  provider = aws.aws_ap_southeast-1

  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

resource "aws_key_pair" "ap_southeast_1_default" {
  provider = aws.aws_ap_southeast-1
  public_key = var.public_key
}

data "aws_availability_zones" "ap_southeast_1_default" {
  provider = aws.aws_ap_southeast-1
}

resource "aws_vpc_peering_connection" "client" {

  vpc_id      = aws_vpc.client.id

  peer_region = "ap-southeast-1"
  peer_vpc_id = aws_vpc.ap_southeast_1_client.id
}

resource "aws_vpc_peering_connection_accepter" "client" {
  provider = aws.aws_ap_southeast-1
  vpc_peering_connection_id = aws_vpc_peering_connection.client.id
  auto_accept = true
}