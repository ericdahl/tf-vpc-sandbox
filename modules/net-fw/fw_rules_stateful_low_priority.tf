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

# copied from AWS managed rules for Exploits
# Test case:
#  curl 'http://example.com/admin/config.php?password\[0\]username=foo'
#drop http any any -> any any (msg:"FreePBX Authentication Bypass (CVE-2019-19006)";flow:established,to_server;http.uri;content:"/admin/config.php?password[0]";content:"username=";distance:0;reference:cve,2019-19006;sid:2846418;rev:1;metadata:affected_product FreePBX,attack_target Web_Server,created_at 2021_01_08,cve CVE_2019_19006,deployment Perimeter,signature_severity Minor;)

drop http $RFC_1918 any -> !$RFC_1918 any (flow:established,to_server; content:"foobar"; sid:11111;)

# response HTML says "Example Domain" here. This will block traffic when making outgoing
# requests from the VPCs to Internet if response has this string
drop http !$RFC_1918 any -> $RFC_1918 any (flow:established; content:"Example"; sid:11112;)

# doesn't drop packets - data flow is not to_server for this case
#drop http !$RFC_1918 any -> $RFC_1918 any (flow:established, to_server; content:"Example"; sid:11112;)


#pass ip $RFC_1918 any -> !$RFC_1918 any (msg: "default allow egress to internet"; sid: 1000001;)
pass ip $RFC_1918 any -> !$RFC_1918 any (flow:established; msg: "default allow egress to internet"; sid: 1000001;)


EOF

    }
  }
}
