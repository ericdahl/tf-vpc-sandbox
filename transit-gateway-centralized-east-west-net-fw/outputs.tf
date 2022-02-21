output "ip" {
  value = {
    dev = {
      vpc_10_1_0_0 = {
        jumphost = {
          public_ip  = module.vpc_10_1_0_0.ec2_jumphost.public_ip
          private_ip = module.vpc_10_1_0_0.ec2_jumphost.private_ip
        }
        internal = {
          public_ip  = module.vpc_10_1_0_0.ec2_internal.public_ip
          private_ip = module.vpc_10_1_0_0.ec2_internal.private_ip
        }
      }
      vpc_10_2_0_0 = {
        jumphost = {
          public_ip  = module.vpc_10_2_0_0.ec2_jumphost.public_ip
          private_ip = module.vpc_10_2_0_0.ec2_jumphost.private_ip
        }
      }
    }
    stage = {
      vpc_10_10_0_0 = {
        jumphost = {
          public_ip  = module.vpc_10_10_0_0.ec2_jumphost.public_ip
          private_ip = module.vpc_10_10_0_0.ec2_jumphost.private_ip
        }
      }
    }
    central = {
      vpc_10_111_0_0 = {
        jumphost = {
          public_ip  = aws_instance.r10_111_0_0_jumphost.public_ip
          private_ip = aws_instance.r10_111_0_0_jumphost.private_ip
        }
      }
    }
  }
}
