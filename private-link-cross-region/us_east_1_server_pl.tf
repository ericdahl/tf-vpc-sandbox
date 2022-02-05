resource "aws_vpc_endpoint_service" "server" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.server.arn]
}