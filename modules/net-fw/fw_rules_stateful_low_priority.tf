resource "aws_networkfirewall_rule_group" "stateful_strict_low_priority" {
  capacity = 100
  name     = "strict-low-priority"
  type     = "STATEFUL"



  rule_group {

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rule_variables {

      ip_sets {
        key = "RFC_1918"
        ip_set {
          definition = local.cidrs_rfc_1918
        }
      }
    }

    rules_source {

    rules_string = <<EOF

#pass ip $RFC_1918 any -> !$RFC_1918 any (msg: "default allow egress to internet"; sid: 1000001;)
pass ip $RFC_1918 any -> !$RFC_1918 any (flow:established,to_server; msg: "default allow egress to internet"; sid: 1000001;)


EOF

    }
  }
}
