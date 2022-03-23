resource "aws_networkfirewall_firewall" "default" {
  vpc_id              = module.vpc_fw.vpc.id
  name                = "transit-gateway-centralized-east-west-net-fw-peer-tgw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.default.arn

  subnet_mapping {
    subnet_id = module.vpc_fw.subnets.private["us-east-1a"].id
  }
}

resource "aws_networkfirewall_firewall_policy" "default" {
  name = "transit-gateway-centralized-east-west-net-fw-peer-tgw"


  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.block_3333_stateless.arn
    }

    stateless_rule_group_reference {
      priority     = 2
      resource_arn = aws_networkfirewall_rule_group.stateless_block_egress_80.arn
    }


    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_2222.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_external_tgw_ingress.arn
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