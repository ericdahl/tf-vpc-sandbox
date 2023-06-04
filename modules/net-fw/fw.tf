resource "aws_networkfirewall_firewall" "default" {
  vpc_id              = var.vpc_id
  name                = "transit-gateway-centralized-east-west-net-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.strict.arn

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "strict" {
  name = "transit-gateway-centralized-east-west-net-fw-strict"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions = [
      "aws:drop_established", "aws:alert_established"
    ]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
#
#    stateless_rule_group_reference {
#      priority     = 2
#      resource_arn = aws_networkfirewall_rule_group.stateless.arn
#    }



    stateful_rule_group_reference {
      priority = 100
      resource_arn = aws_networkfirewall_rule_group.stateful_strict_high_priority.arn
    }
#
#    stateful_rule_group_reference {
#      priority = 200
#      resource_arn = "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/BotNetCommandAndControlDomainsStrictOrder"
#    }
#
#    stateful_rule_group_reference {
#      priority = 300
#      resource_arn = "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/MalwareDomainsStrictOrder"
#    }
#
#    stateful_rule_group_reference {
#      priority = 400
#      resource_arn = "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/AbusedLegitMalwareDomainsStrictOrder"
#    }
#
#    stateful_rule_group_reference {
#      priority = 500
#      resource_arn = "arn:aws:network-firewall:us-east-1:aws-managed:stateful-rulegroup/AbusedLegitBotNetCommandAndControlDomainsStrictOrder"
#    }

    stateful_rule_group_reference {
      priority = 50000
      resource_arn = aws_networkfirewall_rule_group.stateful_strict_low_priority.arn
    }


  }
}

resource "aws_cloudwatch_log_group" "fw_flow" {
  name = "fw-flow"
}


#fields @timestamp, event.alert.action, event.proto, event.src_ip, event.src_port, event.dest_ip, event.dest_port, event.alert.action, event.alert.signature, @message
#| sort @timestamp desc
#| limit 20
resource "aws_cloudwatch_log_group" "fw_alert" {
  name = "fw-alert"
}

resource "aws_networkfirewall_logging_configuration" "default" {
  firewall_arn = aws_networkfirewall_firewall.default.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.fw_flow.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.fw_alert.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}