output "tgw_attachment" {
  value = module.base_vpc.tgw_attachment
}

output "ec2_jumphost" {
  value = module.base_vpc.ec2_jumphost
}

output "ec2_internal" {
  value = module.base_vpc.ec2_internal
}