resource "aws_lb" "server" {
  name = "server-nlb"

  load_balancer_type = "network"
  internal           = true

  subnets = [for s in aws_subnet.server_public : s.id]
}

resource "aws_lb_listener" "server_80" {
  load_balancer_arn = aws_lb.server.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

resource "aws_lb_target_group" "server" {
  vpc_id = aws_vpc.server.id

  port     = 80
  protocol = "TCP"

  deregistration_delay = 0
}

resource "aws_lb_target_group_attachment" "server" {
  target_group_arn = aws_lb_target_group.server.arn
  target_id        = aws_instance.server.id
  port             = 80
}
