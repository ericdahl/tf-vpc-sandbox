output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.default.id
}

output "ec2_jumphost" {
  value = {
    public_ip = aws_instance.jumphost.public_ip,
    private_ip = aws_instance.jumphost.private_ip
  }
}

output "ec2_internal" {
  value = {
    public_ip = aws_instance.internal.public_ip,
    private_ip = aws_instance.internal.private_ip
  }
}