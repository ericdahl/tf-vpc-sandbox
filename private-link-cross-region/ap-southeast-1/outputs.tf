output "vpc_id" {
  value = aws_vpc.client.id
}

output "cidr_block" {
  value = aws_vpc.client.cidr_block
}

output "ec2_public_ip" {
  value = aws_instance.client.public_ip
}

output "ec2_security_group" {
  value = aws_security_group.client.id
}