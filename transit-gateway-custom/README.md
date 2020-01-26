# transit-gateway-custom

_work in progress; only 10.1/10.3 set up;_

sample illustrating connecting five VPCs with a Transit Gateway

This example:
- creates five 10.1./16 ... 10.5/16
- creates a transit gateway with default route table off
    - creates two custom route tables
        - odd: allows "odd" VPCs 10.1/16, 10.3/16, 10.5/16 to route to each other
        - even
- creates a transit gateway attachment each
- updates each VPCs' route table to route 10/8 to transit gateway
- has security groups which are configured to allow traffic from each other

# TODO

- finish all VPCs
- reorg/refactor