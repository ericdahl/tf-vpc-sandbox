variable "cidr_block" {}
variable "tgw_id" {}
variable "admin_ip_cidr" {}
variable "public_key" {}

variable "aws_network_firewall" {}

variable "enable_firewall_inter_vpc" {
  default = true
}