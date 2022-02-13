provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

provider "aws" {
  alias  = "aws_ap_southeast-1"
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Name = "private-link-cross-region"
    }
  }
}

resource "aws_vpc_peering_connection" "client" {
  vpc_id = module.us_east_1.vpc_id

  peer_region = "ap-southeast-1"
  peer_vpc_id = module.ap_southeast_1.vpc_id
}

module "us_east_1" {
  source = "./us-east-1"

  admin_cidrs = var.admin_cidrs
  public_key  = var.public_key

  peer_cidr_block = module.ap_southeast_1.cidr_block

  vpc_peering_connection = aws_vpc_peering_connection.client.id
}

module "ap_southeast_1" {
  source = "./ap-southeast-1"

  public_key  = var.public_key
  admin_cidrs = var.admin_cidrs

  peer_cidr_block        = module.us_east_1.cidr_block
  vpc_peering_connection = aws_vpc_peering_connection.client.id

  providers = {
    aws = aws.aws_ap_southeast-1
  }
}