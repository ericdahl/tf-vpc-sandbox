variable "cidr_block" {
  default = "10.0.0.0/16"
}


variable "admin_ip_cidr" {}

variable "public_key" {}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

