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
curl -v 'http://alb-missing-listener-857426697.us-east-1.elb.amazonaws.com'
* Host alb-missing-listener-857426697.us-east-1.elb.amazonaws.com:80 was resolved.
* IPv6: (none)
* IPv4: 34.193.154.63, 54.84.178.54
*   Trying 34.193.154.63:80...
* connect to 34.193.154.63 port 80 from 10.0.0.17 port 49924 failed: Connection refused
*   Trying 54.84.178.54:80...
* connect to 54.84.178.54 port 80 from 10.0.0.17 port 49925 failed: Connection refused
* Failed to connect to alb-missing-listener-857426697.us-east-1.elb.amazonaws.com port 80 after 148 ms: Couldn't connect to server
* Closing connection
curl: (7) Failed to connect to alb-missing-listener-857426697.us-east-1.elb.amazonaws.com port 80 after 148 ms: Couldn't connect to server
```

```
tcpdump port 80
13:09:48.724969 IP emm.local.49938 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2568649769, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1002496454 ecr 0,sackOK,eol], length 0
13:09:48.797977 IP ec2-34-193-154-63.compute-1.amazonaws.com.http > emm.local.49938: Flags [R.], seq 0, ack 2568649770, win 0, length 0
13:09:48.798485 IP emm.local.49939 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 2901956414, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 3298329626 ecr 0,sackOK,eol], length 0
13:09:48.871389 IP ec2-54-84-178-54.compute-1.amazonaws.com.http > emm.local.49939: Flags [R.], seq 0, ack 2901956415, win 0, length 0
```


Confirmed: immediate failure

## SG refuse 80

```
curl -v 'http://alb-missing-listener-857426697.us-east-1.elb.amazonaws.com'
* Host alb-missing-listener-857426697.us-east-1.elb.amazonaws.com:80 was resolved.
* IPv6: (none)
* IPv4: 54.84.178.54, 34.193.154.63
*   Trying 54.84.178.54:80...
* connect to 54.84.178.54 port 80 from 10.0.0.17 port 49978 failed: Operation timed out
*   Trying 34.193.154.63:80...
* connect to 34.193.154.63 port 80 from 10.0.0.17 port 49987 failed: Operation timed out
* Failed to connect to alb-missing-listener-857426697.us-east-1.elb.amazonaws.com port 80 after 150019 ms: Couldn't connect to server
* Closing connection
curl: (28) Failed to connect to alb-missing-listener-857426697.us-east-1.elb.amazonaws.com port 80 after 150019 ms: Couldn't connect to server


13:11:18.768315 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63523887 ecr 0,sackOK,eol], length 0
13:11:19.767871 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63524887 ecr 0,sackOK,eol], length 0
13:11:20.769256 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63525888 ecr 0,sackOK,eol], length 0
13:11:21.769674 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63526889 ecr 0,sackOK,eol], length 0
13:11:22.771148 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63527890 ecr 0,sackOK,eol], length 0
13:11:23.771796 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63528891 ecr 0,sackOK,eol], length 0
13:11:25.773512 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63530893 ecr 0,sackOK,eol], length 0
13:11:29.774109 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63534893 ecr 0,sackOK,eol], length 0
13:11:37.775005 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63542894 ecr 0,sackOK,eol], length 0
13:11:53.776537 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 63558895 ecr 0,sackOK,eol], length 0
13:12:25.777927 IP emm.local.49978 > ec2-54-84-178-54.compute-1.amazonaws.com.http: Flags [S], seq 3484418578, win 65535, options [mss 1460,sackOK,eol], length 0
13:12:33.769004 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784207341 ecr 0,sackOK,eol], length 0
13:12:34.768977 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784208342 ecr 0,sackOK,eol], length 0
13:12:35.769675 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784209342 ecr 0,sackOK,eol], length 0
13:12:36.770785 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784210343 ecr 0,sackOK,eol], length 0
13:12:37.771922 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784211344 ecr 0,sackOK,eol], length 0
13:12:38.772679 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784212345 ecr 0,sackOK,eol], length 0
13:12:40.773817 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784214346 ecr 0,sackOK,eol], length 0
13:12:44.773698 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784218346 ecr 0,sackOK,eol], length 0
13:12:52.773752 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784226346 ecr 0,sackOK,eol], length 0
13:13:08.775016 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1784242347 ecr 0,sackOK,eol], length 0
13:13:40.775724 IP emm.local.49987 > ec2-34-193-154-63.compute-1.amazonaws.com.http: Flags [S], seq 2989888540, win 65535, options [mss 1460,sackOK,eol], length 0
```
