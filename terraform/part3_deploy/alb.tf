# ===============================
# Security group for ALB
# ===============================
resource "aws_security_group" "alb_sg" {
  name        = "part3-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.part3_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "part3-alb-sg"
  }
}

# ===============================
# Application Load Balancer
# ===============================
resource "aws_lb" "part3_alb" {
  name               = "part3-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "part3-alb"
  }
}

# ===============================
# Target group for Flask backend
# ===============================
resource "aws_lb_target_group" "flask_tg" {
  name        = "flask-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.part3_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# ===============================
# Target group for Express frontend
# ===============================
resource "aws_lb_target_group" "express_tg" {
  name        = "express-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.part3_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

}

# ===============================
# ALB Listener (ONLY port 80)
# Default → Express
# ===============================
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.part3_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express_tg.arn
  }
}

# ===============================
# Listener Rule: /api/* → Flask
# ===============================
resource "aws_lb_listener_rule" "flask_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}
