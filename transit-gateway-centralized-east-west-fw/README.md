# transit-gateway-centralized-nat

Sample of many VPCs sharing NAT Gateway(s) in a centralized way with TGW

This example:

- creates two standard VPCs (10.1, 10.2)
    - attached to TGW
    - default route to TGW
    - has IGWs
- creates central VPC (10.111)
    - has NAT GWs
    - Route Tables
      - Public
      - Private - default to NAT GW
      - Private-TGW - default route to ENI for pfSense
- TGW
    - extra default route to go to central VPC
  

# pfsense

## local proxy

$ ssh -L 1111:10.111.101.111:443 ec2-user@<vpc 111 jumphost ip>

username = admin
password = from console in EC2 (TODO: set static demo password)

- add firewall rule to allow all (deny by default)
-- # TODO figure out how to automate in user-data
