resource "aws_networkfirewall_rule_group" "stateful_strict_high_priority" {
  capacity = 100
  name     = "strict-high-priority"
  type     = "STATEFUL"



  rule_group {

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rules_source {


      stateful_rule {
        action = "DROP"
        header {
          destination      = "0.0.0.0/0"
          destination_port = 2222
          direction        = "ANY"
          protocol         = "TCP"
          source           = "10.0.0.0/8"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }
}
