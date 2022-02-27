

resource "aws_networkfirewall_rule_group" "stateless_block_egress_80" {
  name     = "stateless-block-egress-80"
  type     = "STATELESS"
  capacity = 100


  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 2

          rule_definition {
            actions = [
              "aws:drop",
            ]

            match_attributes {
              protocols = [
                6,
              ]

              destination {
                address_definition = "0.0.0.0/0"
              }

              destination_port {
                from_port = 80
                to_port   = 80
              }

              source {
                address_definition = "0.0.0.0/0"
              }

              source_port {
                from_port = 0
                to_port   = 65535
              }
            }
          }
        }
      }
    }
  }
}


resource "aws_networkfirewall_rule_group" "block_3333_stateless" {
  name     = "block-3333-stateless"
  type     = "STATELESS"
  capacity = 100


  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1

          rule_definition {
            actions = [
              "aws:drop",
            ]

            match_attributes {
              protocols = [
                6,
              ]

              destination {
                address_definition = "0.0.0.0/0"
              }

              destination_port {
                from_port = 3333
                to_port   = 3333
              }

              source {
                address_definition = "0.0.0.0/0"
              }

              source_port {
                from_port = 0
                to_port   = 65535
              }
            }
          }
        }
      }
    }
  }
}
