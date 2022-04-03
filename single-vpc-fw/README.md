# Notes

## flow - no vpc endpoint

@int int to s3
@fw int to s3 (rewrite dest=fw)
@fw int to s3 (rewrite as src=fw)
@nat int to s3 (rewrite dest=nat)
@nat nat to s3

@nat - s3 to nat
@nat s3 to int (rewrite as src=nat)
@int s3 to int



## pfsense steps

- admin gui
- enable LAN interface with DHCP
- NAT - enable outbound NAT to WAN address
  - enable hybrid (automatic doesn't work?)
- FW - 
  - update default LAN rule - update src to remove LAN net (diff subnet) 



