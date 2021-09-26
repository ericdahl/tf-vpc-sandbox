output "vpc1_jumphost_public_ip" {
  value = aws_instance.r10_1_0_0_jumphost.public_ip
}

output "vpc2_jumphost_public_ip" {
  value = aws_instance.r10_2_0_0_jumphost.public_ip
}


output "vpc1_jumphost_private_ip" {
  value = aws_instance.r10_1_0_0_jumphost.private_ip
}

output "vpc2_jumphost_private_ip" {
  value = aws_instance.r10_2_0_0_jumphost.private_ip
}