resource "aws_networkfirewall_rule_group" "stateful_strict_high_priority" {
  capacity = 100
  name     = "strict-high-priority"
  type     = "STATEFUL"



  rule_group {

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rules_source {

      rules_string = <<EOF
# nothing
EOF

    }
  }
}
