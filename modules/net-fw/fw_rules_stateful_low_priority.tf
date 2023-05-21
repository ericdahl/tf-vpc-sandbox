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

pass icmp $RFC_1918 any -> any any (msg: "allow all rfc1918 icmp"; sid: 1;)

# example - drop requests from "bad_user" HTTP User Agent
drop http $RFC_1918 any -> any any (content: "bad_user"; http_user_agent; sid: 2; rev: 1;)

# allow http to example.com domain
pass http $RFC_1918 any -> !$RFC_1918 80 (http.host; dotprefix; content:".example.com"; endswith; msg:"Allowed HTTP domain"; sid:3; rev:1;)

# allow http/tls to .amazon and example.com
pass tls $RFC_1918 any -> !$RFC_1918 any (tls.sni; dotprefix; content:".amazon.com"; nocase; endswith; msg:"matching TLS allowlisted FQDNs"; flow:to_server, established; sid:4; rev:1;)
pass tls $RFC_1918 any -> !$RFC_1918 any (tls.sni; content:"httpbin.org"; startswith; nocase; endswith; msg:"matching TLS allowlisted FQDNs"; flow:to_server, established; sid:5; rev:1;)

# temporary? could refine to just allow for yum updates..?
pass tls any any -> any any (msg: "allow all tls"; sid:6;)


pass tcp any any -> any 5201 (msg: "allow iperf3 testing"; sid:7;)


pass ip $RFC_1918 any -> any any (msg: "allow all egress temp"; sid: 8;)

# log anything that did not pass/drop yet
#alert http any any -> any 80 (msg: "alert all http port 80"; sid: 7;)
#alert tls any any -> any 443 (msg: "alert all https port 443"; sid: 8;)

EOF

    }
  }
}
