# alb-missing-listener

Goal: Observe behavior of connecting to ALB on port 80 when Listener is missing vs SG lacking a rule, w/r/t TCP Resets vs not.

Hypothesis: if SG permits 80 and ALB lacks listener, then ALB returns RST. If SG does not permit 80 then ALB has no reply packets leading to a connection timeout on client. That is, one scenario results in immediate failure while other is a timeout.

# Tests

## Base functionality - SG permit 80 and ALB has listener

```bash
curl -v 'http://alb-missing-listener-857426697.us-east-1.elb.amazonaws.com'
* Host alb-missing-listener-857426697.us-east-1.elb.amazonaws.com:80 was resolved.
* IPv6: (none)
* IPv4: 54.84.178.54
*   Trying 54.84.178.54:80...
* Connected to alb-missing-listener-857426697.us-east-1.elb.amazonaws.com (54.84.178.54) port 80
> GET / HTTP/1.1
> Host: alb-missing-listener-857426697.us-east-1.elb.amazonaws.com
> User-Agent: curl/8.7.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 301 Moved Permanently
< Server: awselb/2.0
< Date: Mon, 11 Aug 2025 20:07:26 GMT
< Content-Type: text/html
< Content-Length: 134
< Connection: keep-alive
< Location: https://example.com:443/
< 
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
</body>
</html>
* Connection #0 to host alb-missing-listener-857426697.us-east-1.elb.amazonaws.com left intact
```

## SG permit 80 & ALB lacks port 80 listener

```bash
curl ..
```
