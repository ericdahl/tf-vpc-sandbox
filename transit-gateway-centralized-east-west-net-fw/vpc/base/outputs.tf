output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.default.id
}

output "ec2_jumphost" {
  value = {
    public_ip  = aws_instance.jumphost.public_ip,
    private_ip = aws_instance.jumphost.private_ip
  }
}

output "ec2_internal" {
  value = {
    public_ip  = aws_instance.internal.public_ip,
    private_ip = aws_instance.internal.private_ip
  }
}

output "route_tables" {
  value = {
    public = aws_route_table.public
    private = aws_route_table.private
    tgw = aws_route_table.tgw
  }
}

output "tgw_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.default
}

output "subnets" {
  value = {
    public = aws_subnet.public
    private = aws_subnet.private
    tgw = aws_subnet.tgw
  }
}

output "vpc" {
  value = aws_vpc.default
}

output "igw" {
  value = aws_internet_gateway.default
}