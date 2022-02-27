# transit-gateway-centralized-east-west-net-fw

See [transit-gateway-centralized-east-west-fw](../transit-gateway-centralized-east-west-fw)

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
