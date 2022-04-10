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


pass http $RFC_1918 any -> $EXTERNAL_NET 80 (http.host; dotprefix; content:".example.com"; endswith; msg:"Allowed HTTP domain"; sid:892120; rev:1;)
pass tcp $RFC_1918 any <> $EXTERNAL_NET 80 (flow:not_established; sid:892191; rev:1;)


alert http any any -> any 80 (msg: "alert all http port 80"; sid: 1234;)

EOF

    }
  }
}
