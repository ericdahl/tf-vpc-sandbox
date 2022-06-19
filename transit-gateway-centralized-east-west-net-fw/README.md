# transit-gateway-centralized-east-west-net-fw

See [transit-gateway-centralized-east-west-fw](../transit-gateway-centralized-east-west-ec2-fw)

but with AWS Network Firewall instead

Rules:
- Block tcp 2222 for any dest with stateful FW
- block tcp 3333 for any dest with stateless fw

# Demo

```

# set up fake server
ssh ec2-user@<jumphost for 10.10.0.0/16>
$ python3 -m http.server 2222

# try to connect from client
ssh ec2-user@<jumphost for 10.1>
$ curl http://<private ip for jumphsost for 10.10.0.0/16>:2222/
curl: (28) Failed to connect to 10.10.1.115 port 2222: Connection timed out

```

# Notes

## East-West inspection within VPC

- <https://aws.amazon.com/blogs/aws/inspect-subnet-to-subnet-traffic-with-amazon-vpc-more-specific-routing/>

- Can this be utilized to route to TGW directly (to get through central FW)?
  - No, route target must be ENI/instance in VPC
- Can some workaround be done to achieve this?
  - Not really
  - Thought about appliance per VPC to forward to TGW but route limitations still apply

If VPC Subnet Route table has same CIDR as VPC, pointing to TGW:

```
The destination CIDR block 10.1.0.0/16 is equal to or more specific than one of this VPC's CIDR blocks. This route can target only an interface or an instance.
```

If trying to a specific subnet, pointing to TGW:

```
The destination CIDR block 10.1.102.0/24 is equal to or more specific than one of this VPC's CIDR blocks. This route can target only an interface or an instance.
```

## Route Propagation

- FW VPC must be associated to TGW Route table which knows how to route to each VPC
  - Two options
    - Create dedicated central/tgw VPC and ensure routes for every VPC attachment are in place
    - Leverage "TGW default propagation table"
      - Any VPC attachment has the VPC CIDR(s) automatically injected in this route table
      - FW VPC TGW-Attachments are then Associated to this table
      - benefit: fewer updates per new VPC
      - con: less explicit, maybe confusing

## TF Design of VPCs

- Workload and FW VPCs are similar but not the same; how to reconcile?
  - modularize workload VPC; keep FW VPC custom
  - toggles in common VPC module
    - private subnets: whether to have default routes to TGW or NAT GW
    - tgw subnets: whether to have default routes to TGW or VPC-E for FW
  - workload module and fw module, built on common base vpc module
    - routes defined in {fw,workload} module
    - current implementation
      - least duplication, but adds some complexity (not worth it?)


## questions
- how did inter VPC traffic work (10.1 to 10.2) if FW VPC private subnet had no route to TGW?
  - route was missing
  - FW is in private subnet, it would receive packets but need to forward to TGW again
  - somehow NAT GW was routing traffic
    - also, example: FW instance -> 10.2
      - 2 routes: 
        - local VPC
        - default to nat GW
          - how does this work?
          - with freebsd, 
            - missing route: okay
            - add rfc1918 routes to tgw: results in "redirect host nexthop 0.0.0.0"


## performance

- iperf3
- instances are c5n.large
- Test 1: loopback interface
  - 73 Gbps / 9 GBps
- Test 2: across TGW/FW, same AZ
  - 4.7 Gbps / 0.5
- Test 3: same VPC, same AZ, placement group
  - 9.5 Gpbs / 1.2 GPbs

## Network Firewall
            
- HOME_NET is VPC FW CIDR; generally not appropriate. Need to set to RFC 1918

### Example Log - default drop

```json
{
    "firewall_name": "transit-gateway-centralized-east-west-net-fw",
    "availability_zone": "us-east-1a",
    "event_timestamp": "1649620611",
    "event": {
        "timestamp": "2022-04-10T19:56:51.558394+0000",
        "flow_id": 712183795996134,
        "event_type": "alert",
        "src_ip": "10.1.128.133",
        "src_port": 39582,
        "dest_ip": "34.231.5.222",
        "dest_port": 80,
        "proto": "TCP",
        "alert": {
            "action": "blocked",
            "signature_id": 4,
            "rev": 0,
            "signature": "aws:alert_established action",
            "category": "",
            "severity": 3
        },
        "http": {
            "hostname": "httpbin.org",
            "url": "/ip",
            "http_user_agent": "curl/7.79.1",
            "http_method": "GET",
            "protocol": "HTTP/1.1",
            "length": 0
        },
        "app_proto": "http"
    }
}
```