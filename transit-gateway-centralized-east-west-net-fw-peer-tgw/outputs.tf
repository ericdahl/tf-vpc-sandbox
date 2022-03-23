output "vpc" {
  value = {
    dev   = module.vpc_dev
    stage = module.vpc_stage
    fw    = module.vpc_fw
  }
}

output "external" {
  value = module.external
}