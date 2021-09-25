output "vpc1_jumphost_public_ip" {
  value = aws_instance.r10_1_0_0_jumphost.public_ip
}

output "vpc2_jumphost_public_ip" {
  value = aws_instance.r10_2_0_0_jumphost.public_ip
}

//output "vpc3_jumphost_public_ip" {
//  value = aws_instance.r10_3_0_0_jumphost.public_ip
//}
//
//output "vpc4_jumphost_public_ip" {
//  value = aws_instance.r10_4_0_0_jumphost.public_ip
//}
//
//output "vpc5_jumphost_public_ip" {
//  value = aws_instance.r10_5_0_0_jumphost.public_ip
//}

output "vpc1_jumphost_private_ip" {
  value = aws_instance.r10_1_0_0_jumphost.private_ip
}

output "vpc2_jumphost_private_ip" {
  value = aws_instance.r10_2_0_0_jumphost.private_ip
}
//
//output "vpc3_jumphost_private_ip" {
//  value = aws_instance.r10_3_0_0_jumphost.private_ip
//}
//
//output "vpc4_jumphost_private_ip" {
//  value = aws_instance.r10_4_0_0_jumphost.private_ip
//}
//
//output "vpc5_jumphost_private_ip" {
//  value = aws_instance.r10_5_0_0_jumphost.private_ip
//}