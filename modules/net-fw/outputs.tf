output "vpc_endpoints" {
  value = tolist(aws_networkfirewall_firewall.default.firewall_status[0].sync_states)[0].attachment[0]
}