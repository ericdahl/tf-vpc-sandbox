output "us_east_1" {
  value = {
    client = {
      public_ip = module.us_east_1.ec2_public_ip
    }

    server = {
      private_link = {
        dns = module.us_east_1.client_pl_dns
      },
      nlb = {
        dns = module.us_east_1.nlb_dns
      }
    }
  }
}

output "ap_southeast_1" {
  value = {
    client = {
      public_ip = module.ap_southeast_1.ec2_public_ip
    }
  }
}

