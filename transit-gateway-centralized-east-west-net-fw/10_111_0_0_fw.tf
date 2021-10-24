resource "aws_networkfirewall_firewall" "default" {
  vpc_id              = aws_vpc.vpc_10_111_0_0.id
  name                = "transit-gateway-centralized-east-west-net-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.default.arn

  subnet_mapping {
    subnet_id = aws_subnet.r10_111_0_0_public1.id
  }



}

resource "aws_networkfirewall_firewall_policy" "default" {
  name = "transit-gateway-centralized-east-west-net-fw"


  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
        stateless_rule_group_reference {
          priority     = 1
          resource_arn = aws_networkfirewall_rule_group.block_2222_stateless.arn
        }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_2222.arn
    }
  }
}


resource "aws_networkfirewall_rule_group" "block_2222" {
  capacity = 100
  name     = "block-2222"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "0.0.0.0/8"
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

resource "aws_networkfirewall_rule_group" "block_2222_stateless" {
  name     = "block-2222-stateless"
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
                from_port = 2222
                to_port   = 2222
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




resource "aws_cloudwatch_log_group" "fw" {
  name = "fw"
}

resource "aws_networkfirewall_logging_configuration" "default" {
  firewall_arn = aws_networkfirewall_firewall.default.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.fw.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}