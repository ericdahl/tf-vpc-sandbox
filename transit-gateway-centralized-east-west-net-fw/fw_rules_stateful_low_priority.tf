resource "aws_networkfirewall_rule_group" "stateful_strict_low_priority" {
  capacity = 100
  name     = "strict-low-priority"
  type     = "STATEFUL"



  rule_group {

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rules_source {

    rules_string = <<EOF


#drop http 10.1.128.40 any -> any any (msg: "alert one host"; sid: 5;)

#pass ip any any -> any any (msg: "allow everything"; sid: 6;)

pass http $HOME_NET any -> $EXTERNAL_NET 80 (http.host; dotprefix; content:".example.com"; endswith; msg:"Allowed HTTP domain"; sid:892120; rev:1;)
pass tcp $HOME_NET any <> $EXTERNAL_NET 80 (flow:not_established; sid:892191; rev:1;)


EOF

    }
  }
}
