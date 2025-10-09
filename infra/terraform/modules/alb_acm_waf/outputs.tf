output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.alb.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix (used by CloudWatch metrics)"
  value       = aws_lb.alb.arn_suffix
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_sg_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb_sg.id
}

output "tg_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.tg.arn
}

output "tg_arn_suffix" {
  description = "Target group ARN suffix"
  value       = aws_lb_target_group.tg.arn_suffix
}
