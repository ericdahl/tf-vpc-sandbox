provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "transit-gateway-transition"
    }
  }
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


resource "aws_key_pair" "default" {
  public_key = var.public_key
}


module "vpc_workload" {
  source = "../modules/vpc/workload"

  for_each = toset([
    "10.1.0.0/16",
    "10.2.0.0/16",
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.legacy.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  tgw_default_route_association = true
}

module "vpc_workload_new_only" {
  source = "../modules/vpc/workload"

  for_each = toset([
    "10.11.0.0/16",
    "10.22.0.0/16",
  ])
  cidr_block = each.value
  tgw_id     = aws_ec2_transit_gateway.new.id

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key

  tgw_default_route_association = true
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_10_1_0_0_new" {
  subnet_ids         = [ for s in module.vpc_workload["10.1.0.0/16"].subnets.tgw: s.id ]
  transit_gateway_id = aws_ec2_transit_gateway.new.id
  vpc_id             = module.vpc_workload["10.1.0.0/16"].vpc.id

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

# WARNING: hard-coded route table ID
resource "aws_route" "migrate" {
  route_table_id = module.vpc_workload["10.1.0.0/16"].route_tables.public.id

  destination_cidr_block = module.vpc_workload_new_only["10.11.0.0/16"].vpc.cidr_block

  transit_gateway_id = aws_ec2_transit_gateway.new.id
}
