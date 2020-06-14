resource aws_lb joneteus-spring-petclinic-alb {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.joneteus-spring-petclinic-alb-sg.id]
  subnets            = [
    aws_subnet.public-subnet-a.id, 
    aws_subnet.public-subnet-b.id, 
    aws_subnet.public-subnet-c.id
  ]
}

resource aws_security_group joneteus-spring-petclinic-alb-sg {
  name_prefix = "${var.app_name}-alb"
  description = "Security group for ${var.app_name} Application Load Balancer"
  vpc_id      = aws_vpc.joneteus-spring-petclinic-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.app_access_cidr ]
  }
}

resource aws_lb_listener joneteus-spring-petclinic-http  {
  load_balancer_arn = aws_lb.joneteus-spring-petclinic-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.joneteus-spring-petclinic-tg.arn
  }
}

resource aws_lb_target_group joneteus-spring-petclinic-tg {
  name     = "${var.app_name}-alb-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.joneteus-spring-petclinic-vpc.id
}
