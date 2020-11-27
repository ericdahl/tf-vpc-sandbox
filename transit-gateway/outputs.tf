output "aws_instance_vpc_10_1_0_0_jumphost_public_ip" {
  value = aws_instance.vpc_10_1_0_0_jumphost.public_ip
}

output "aws_instance_vpc_10_1_0_0_jumphost_private_ip" {
  value = aws_instance.vpc_10_1_0_0_jumphost.private_ip
}

output "aws_instance_vpc_10_2_0_0_jumphost_public_ip" {
  value = aws_instance.vpc_10_2_0_0_jumphost.public_ip
}

output "aws_instance_vpc_10_2_0_0_jumphost_private_ip" {
  value = aws_instance.vpc_10_2_0_0_jumphost.private_ip
}