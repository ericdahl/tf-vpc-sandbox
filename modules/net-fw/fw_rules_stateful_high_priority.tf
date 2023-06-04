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

#drop http any any -> any any (http.user_agent; content:"bad_agent"; sid:10000;)
#pass http any any -> any any (sid: 12321231;)

# does NOT work - AWS config issue?
#drop tcp any any -> any 80 (flow:established,to_server;content: "foobar"; sid: 1231;)
#pass tcp any any -> any 80 (sid: 1221111;)

# works - for initial payload only
drop http any any -> any 80 (flow:established,to_server;content: "foobar"; sid: 1231;)
pass http any any -> any 80 (sid: 1221111;)

EOF

    }
  }
}
