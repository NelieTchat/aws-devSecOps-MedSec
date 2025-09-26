output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "ALB ARN."
}

output "alb_dns" {
  value       = aws_lb.alb.dns_name
  description = "Public DNS name of the ALB."
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ALB security group ID."
}

output "tg_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "Target group ARN for the service."
}
