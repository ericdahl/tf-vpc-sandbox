# transit-gateway

sample illustrating connecting two VPCs with a Transit Gateway

This example:
- creates two VPCs 10.1/16 and 10.2/16
- creates a transit gateway
- creates a transit gateway attachment for both VPCs
- updates each VPCs' route table to route 10./8 to transit gateway
- has security groups which are configured to allow traffic from each other