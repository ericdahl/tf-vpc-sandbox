output "aws_instance_10_1_0_0_jumphost_public_ip" {
  value = aws_instance.jumphost_10_1_0_0_jumphost.public_ip
}

output "aws_instance_10_1_0_0_jumphost_private_ip" {
  value = aws_instance.jumphost_10_1_0_0_jumphost.private_ip
}

output "aws_instance_10_2_0_0_jumphost_public_ip" {
  value = aws_instance.jumphost_10_2_0_0_jumphost.public_ip
}

output "aws_instance_10_2_0_0_jumphost_private_ip" {
  value = aws_instance.jumphost_10_2_0_0_jumphost.private_ip
}

output "data_aws_ami_freebsd_11_id" {
  value = data.aws_ami.freebsd_11.id
}

output "aws_vpc_endpoint_nlb_dns_entry" {
  value = aws_vpc_endpoint.nlb.dns_entry
}

