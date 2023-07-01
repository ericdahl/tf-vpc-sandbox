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

# test case -
## curl --max-time 5 -v http://10.2.128.210/?[1230-1240]
# Note: misconfigured - does not block 1234 if connection established already
#drop http any any -> any 80 (flow:established,to_server;content: "1234"; sid: 1;)
#pass http any any -> any 80 (sid: 2;)

# Fix for above, drops 1234 request in middle of flow, curl creates new conn/flow
drop http any any -> any 80 (flow:established,to_server;content: "1234"; sid: 1;)
pass tcp any any -> any 80 (flow:established,to_server;sid: 2;)

#drop http any any -> any any (http.user_agent; content:"bad_agent"; sid:10000;)
#pass http any any -> any any (sid: 12321231;)

# does NOT work - AWS config issue?
#drop tcp any any -> any 80 (flow:established,to_server;content: "foobar"; sid: 1231;)
#pass tcp any any -> any 80 (sid: 1221111;)

# works - for initial payload only
#drop http any any -> any 80 (flow:established,to_server;content: "foobar"; sid: 1231;)
#pass http any any -> any 80 (sid: 1221111;)

EOF

    }
  }
}
