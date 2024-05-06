output "ip" {
  value = {
    client = aws_instance.client.public_ip
    server = aws_instance.server.public_ip
  }
}

output "alb" {
  value = aws_lb.alb.dns_name
}

output "access_log" {
  value = aws_s3_bucket.alb_logs.bucket
}