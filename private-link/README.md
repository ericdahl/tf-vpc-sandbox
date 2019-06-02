# private-link

sample illustrating using a PrivateLink endpoint to allow access 
to a NLB across VPCs

This example:
- creates two VPCs 10.1/16 and 10.2/16
- creates a NLB / TG pointing to a nginx host in 10.1/16
- creates a VPC Endpoint Service in 10.1/16 pointing to the NLB
- creates a VPC Endpoint in 10.2/16 pointing to the VPC Endpoint Service above
    - this allows VPC2 to access the nginx host in VPC1