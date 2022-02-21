output "vpc" {
  value = {
    vpc_10_1_0_0 = module.vpc_10_1_0_0
    vpc_10_2_0_0 = module.vpc_10_2_0_0
    vpc_10_3_0_0 = module.vpc_10_3_0_0
    vpc_10_10_0_0 = module.vpc_10_10_0_0
  }
}

output "vpc2" {
  value = module.vpc
}