# tf-vpc-sandbox

A sandbox testing out various VPC configurations

- [VPC peering](vpc-peering)
- [PrivateLink](private-link)
- [Transit Gateway](transit-gateway)
- [Transit Gateway Custom](transit-gateway-custom)
    - more complex routing setup
  

# Misc notes


- TGW Attachments
  - Types:
    - VPC - Linked to a single VPC
    - VPN - Linked to a Customer Gateway (internet-routable IP for on-prem device)
    - Peering Connection - Linked to another TGW, possibly in a different region/account
    - Connect - Linked to 3rd party virtual appliance (SD-WAN)
- Route Table Propagation
  - Allows TGW-A (e.g., VPC) to propagate routes from itself to TGW Route Table

- VPC 1-* VPC Attachment
- TGW Attachment 1-1 TGW Route Table association
  - TGW-A can only be associated to one route table
- VPC can be attached up to once to a particular TGW 
