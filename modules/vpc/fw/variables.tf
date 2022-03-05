variable "cidr_block" {}
variable "tgw_id" {}
variable "admin_ip_cidr" {}
variable "public_key" {}

variable "tgw_default_route_fw_vpc_endpoint_id" {
  default = null
}

variable "tgw_default_route_fw_eni" {
  default = null
}

variable "enable_firewall_inter_vpc" {
  default = true
}