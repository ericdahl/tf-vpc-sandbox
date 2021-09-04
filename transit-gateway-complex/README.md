# transit-gateway-complex

sample illustrating connecting five VPCs with a Transit Gateway

This example:
- creates five VPCs, with CIDRs: 10.1./16 ... 10.5/16
- creates a transit gateway with default route table off
    - creates two custom route tables
        - odd
            - 0.0.0.0/0 -> blackhole
            - 10.1.0.0.0/16 -> tgw attachment for 10.1/16 VPC
            - 10.3.0.0.0/16 -> tgw attachment for 10.3/16 VPC
            - 10.5.0.0.0/16 -> tgw attachment for 10.5/16 VPC
        - even
            - 0.0.0.0/0 -> blackhole
            - 10.2.0.0.0/16 -> tgw attachment for 10.2/16 VPC
            - 10.4.0.0.0/16 -> tgw attachment for 10.4/16 VPC
- updates each VPCs' route table to route 10/8 to transit gateway
- has security groups which are configured to allow traffic from each other
