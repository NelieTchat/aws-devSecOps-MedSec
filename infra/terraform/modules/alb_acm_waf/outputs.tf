output "alb_dns" {
  value       = aws_lb.alb.dns_name
  description = "ALB DNS name."
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ALB security group ID."
}

output "tg_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "ALB target group ARN."
}

output "alb_arn_suffix" {
  value       = aws_lb.alb.arn_suffix
  description = "ALB ARN suffix (e.g., app/medsec-dev-alb/xxxxxxxx)."
}

output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "ALB ARN"
}

output "tg_arn_suffix" {
  value       = aws_lb_target_group.tg.arn_suffix
  description = "Target group ARN suffix (e.g., targetgroup/medsec-dev-tg/yyyyyyyy)."
}
