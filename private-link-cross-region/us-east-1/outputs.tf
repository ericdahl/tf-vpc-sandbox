output "vpc_id" {
  value = aws_vpc.client.id
}

output "cidr_block" {
  value = aws_vpc.client.cidr_block
}

output "ec2_public_ip" {
  value = aws_instance.client.public_ip
}

output "pl_endpoint_dns" {
  value = aws_vpc_endpoint.client_interface.dns_entry
}

output "nlb_dns" {
  value = aws_lb.server.dns_name
}