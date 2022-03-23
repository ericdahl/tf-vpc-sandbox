resource "aws_networkfirewall_rule_group" "block_2222" {
  capacity = 100
  name     = "block-2222"
  type     = "STATEFUL"

  rule_group {
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


resource "aws_networkfirewall_rule_group" "block_external_tgw_ingress" {
  capacity = 100
  name     = "block-external-tgw-ingress"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "0.0.0.0/0"
          destination_port = 2222
          direction        = "ANY"
          protocol         = "TCP"
          source           = "172.31.0.0/16"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }
}
