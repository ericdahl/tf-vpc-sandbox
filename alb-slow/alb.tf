resource "aws_lb" "alb" {

  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]

  subnets = [for s in aws_subnet.public : s.id]
  idle_timeout = 60
}

resource "aws_lb_listener" "alb_http_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.lb_target_group.arn
      }
    }
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "server" {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = aws_instance.server.id
}

resource "aws_lb_listener" "alb_http_8888" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8888
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "alb_ingress" {
  security_group_id = aws_security_group.alb.id

  type     = "ingress"
  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]

  from_port = 80
  to_port   = 8888
}

resource "aws_security_group_rule" "alb_egress_all" {
  security_group_id = aws_security_group.alb.id

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}