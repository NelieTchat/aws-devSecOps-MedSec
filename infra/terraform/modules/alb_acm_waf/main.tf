resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Public ALB SG"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

resource "aws_lb" "alb" {
  name                       = "${var.name}-alb"
  load_balancer_type         = "application"
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.alb_sg.id]
  idle_timeout               = 60
  enable_deletion_protection = false

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

# Target Group for ECS (HTTP on 8080)
resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-tg"
  vpc_id      = var.vpc_id
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

# Listener(s)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # If HTTPS is enabled and cert provided, redirect HTTP->HTTPS
  dynamic "default_action" {
    for_each = var.https && var.certificate_arn != "" ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # Otherwise, forward HTTP directly to the target group
  dynamic "default_action" {
    for_each = var.https && var.certificate_arn != "" ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.https && var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Optional: WAFv2 (regional)
resource "aws_wafv2_web_acl" "waf" {
  count = var.waf_enabled ? 1 : 0
  name  = "${var.name}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Common"
      sampled_requests_enabled   = true
    }

    override_action {
      none {}
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-waf" })
}

resource "aws_wafv2_web_acl_association" "assoc" {
  count        = var.waf_enabled ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.waf[0].arn
}
