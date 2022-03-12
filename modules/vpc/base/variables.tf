variable "cidr_block" {}

variable "tgw_id" {}

variable "admin_ip_cidr" {}

variable "public_key" {}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_internal_az" {
  default = "us-east-1a"
}

variable "ec2_jumphost_az" {
  default = "us-east-1a"
}

variable "tgw_default_route_association" {
  default = false
}

variable "tgw_default_route_propagation" {
  default = true
}
