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