# private-link

sample illustrating using a PrivateLink endpoint to allow access 
to a NLB across VPCs

This example:
- creates two VPCs 10.1/16 and 10.2/16
- creates a NLB / TG pointing to a nginx host in 10.1/16
- creates a VPC Endpoint Service in 10.1/16 pointing to the NLB
- creates a VPC Endpoint in 10.2/16 pointing to the VPC Endpoint Service above
    - this allows VPC2 to access the nginx host in VPC1
  

# Commands

```
# log in to jumphost in VPC #2
$ ssh -J ec2-user@<10_2_0_0_jumphost>

# make request to webserver in VPC #1 via PrivateLink endpoint
$ curl <aws_vpc_endpoint_nlb_dns_entry>
```