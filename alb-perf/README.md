## alb-perf

Experiments with HTTP performance of HTTP 1.0 with apachebench

- ab uses HTTP 1.0 with no persistent connections by default
  - means new SYN/connections each request
  - easy to flood server with TIME_WAIT sockets, exhausting it
    - only ~14,100 even numbered ephemeral ports in default settings (AL2)
  - `-k` for keep-alive has no issues
- client ephemeral ports
  - only uses even numbered ports
  - starts at 32768 and ends at 60998
- ALB has similar issue, as expected

```
[ec2-user@ip-10-0-0-249 ~]$ cat /proc/sys/net/ipv4/ip_local_port_range
32768	60999
```

### Client
```
[ec2-user@ip-10-0-0-130 ~]$ ab -n 10000 http://10.0.0.249/
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 10.0.0.249 (be patient)
Completed 1000 requests
apr_pollset_poll: The timeout specified has expired (70007)
Total of 1117 requests completed
```

#### Client to ALB

in this example `10.0.0.95` is one of the ENIs of the ALB, in the same AZ

```
[root@ip-10-0-0-130 ~]# tcpdump -nn host 10.0.0.95 and tcp[tcpflags] == tcp-syn 

...
18:38:52.769612 IP 10.0.0.130.51662 > 10.0.0.95.80: Flags [S], seq 1605825602, win 26883, options [mss 8961,sackOK,TS val 1249714174 ecr 0,nop,wscale 7], length 0
18:38:52.771621 IP 10.0.0.130.51664 > 10.0.0.95.80: Flags [S], seq 2551784945, win 26883, options [mss 8961,sackOK,TS val 1249714176 ecr 0,nop,wscale 7], length 0
18:38:52.772597 IP 10.0.0.130.51674 > 10.0.0.95.80: Flags [S], seq 1258479354, win 26883, options [mss 8961,sackOK,TS val 1249714177 ecr 0,nop,wscale 7], length 0
18:38:52.773792 IP 10.0.0.130.51676 > 10.0.0.95.80: Flags [S], seq 1743396336, win 26883, options [mss 8961,sackOK,TS val 1249714178 ecr 0,nop,wscale 7], length 0
18:38:52.774719 IP 10.0.0.130.51678 > 10.0.0.95.80: Flags [S], seq 1497942418, win 26883, options [mss 8961,sackOK,TS val 1249714179 ecr 0,nop,wscale 7], length 0
18:38:53.784457 IP 10.0.0.130.51678 > 10.0.0.95.80: Flags [S], seq 1497942418, win 26883, options [mss 8961,sackOK,TS val 1249715189 ecr 0,nop,wscale 7], length 0
18:38:55.800446 IP 10.0.0.130.51678 > 10.0.0.95.80: Flags [S], seq 1497942418, win 26883, options [mss 8961,sackOK,TS val 1249717205 ecr 0,nop,wscale 7], length 0
18:38:59.832447 IP 10.0.0.130.51678 > 10.0.0.95.80: Flags [S], seq 1497942418, win 26883, options [mss 8961,sackOK,TS val 1249721237 ecr 0,nop,wscale 7], length 0

```

### Server - nginx

```
[ec2-user@ip-10-0-0-249 ~]$ ss --numeric -o state time-wait | awk '{print $5 "  " $6}' | wc -l
8193

...

10.0.0.130:32768  timer:(timewait,25sec,0)
10.0.0.130:32770  timer:(timewait,44sec,0)
10.0.0.130:32772  timer:(timewait,44sec,0)
...
10.0.0.130:60994  timer:(timewait,28sec,0)
10.0.0.130:60998  timer:(timewait,44sec,0)
```

