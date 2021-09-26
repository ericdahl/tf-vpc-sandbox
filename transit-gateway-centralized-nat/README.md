# transit-gateway-centralized-nat

Sample of many VPCs sharing NAT Gateway(s) in a centralized way with TGW




This example:

- creates two standard VPCs (10.1, 10.2)
    - attached to TGW
    - default route to TGW
- creates central VPC (10.111)
    - has NAT GWs
- TGW
    - extra default route to go to central VPC
    