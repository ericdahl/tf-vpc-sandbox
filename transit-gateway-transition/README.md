# transit-gateway-transition

See [transit-gateway-centralized-east-west-net-fw](../transit-gateway-centralized-east-west-net-fw)

This focuses on transitioning from a simple pass-through TGW to inspection TGW

## Steps

### Pre-req

Provision to get "legacy" TGW set up working

### Transition Steps

#### Non-disruptive setup

1. (no-disruption) Set up New-TGW and empty route tables
2. (no-disruption) Create TGW-Attachments from VPC to New-TGW
   1. VPCs will have active TGW-A to Legacy-TGW and second inactive TGW-A to New-TGW
3. (no-disruption) Create TGW Associations to New-TGW Route tables
4. (no-disruption) Set up Routes in New-TGW
   1. In this case, for central FW, only central table has routes to VPC (other tables route to FW VPC)

#### Flip the switch

1. (no-disruption) Update first VPC routes to go to New-TGW
   1. observed no disruption
   2. asymmetric routing (A -> B via TGW-New and B -> A via TGW-Legacy)
      1. but, works fine with no appliances that could get confused (firewall state tables)

TODO:
- confirm behavior. after this step, ping continues to work.. but
  - initially..
    - CW metrics for TGW-New show no bytes/packets
    - CW metrics for FW show no activity
  - then, metrics show up for New-TGW but not Legacy-TGW


New-TGW FW-VPC TGW-A ENIs 
a - 0c28c254c09b92e82 - echos A -> FW-VPC
c - 0b7d96f60f14209f3 - NODATA
b - 09700810eafc1d6db - NODATA

Legacy-TGW B-VPC TGW-A ENIs tgw-attach-0365cc97444c48a03
a - 053d8406586197f25 - replies B -> B-TGW-A

CW metrics still showing only New-TGW after 15 minutes

Bug? how can overall TGW metric show no activity while TGW-A within TGW show activity
- CW Metric for Per-TGW for Legacy-TGW showing _no data_
- CW Metric for Per-TGW-TGWA for Legacy-TGW showing data

### Migration Path Review

10.1 internal src -> 10.11 internal dest

1. 10.1 internal
2. 10.1 VPC subnet route to TGW-New
3. TGW-New association in place to single table
4. TGW-New route to 10.11 VPC
5. 10.11 VPC TGW-A route to local VPC
6. 10.11 instance receives ECHO
7. 10.11 sends ECHO REPLY
8. subnet routes to TGW-New (default route)
9. TGW-New association in place to single table
10. TGW-New routes to 10.1 VPC (propagated route)
11. 10.1 VPC TGW-A route to local VPC
12. 10.1 instance receives ECHO REPLY