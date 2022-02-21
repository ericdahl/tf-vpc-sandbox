output "vpc" {
  value = {
    dev   = module.vpc_dev
    stage = module.vpc_stage
  }
}