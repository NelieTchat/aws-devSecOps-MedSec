output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Private subnets for ECS"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnets for ALB"
}

output "alb_dns" {
  value       = module.alb.alb_dns_name
  description = "Public DNS of the ALB"
}

output "ecr_repo_url" {
  value       = module.ecr_portal.repository_url
  description = "ECR repo URL"
}

output "ecs_cluster_arn" {
  value       = module.ecs_cluster.cluster_arn
  description = "ECS cluster ARN"
}

output "service_name" {
  value       = module.ecs_service.service_name
  description = "ECS service name"
}

output "ci_role_arn" {
  value       = module.iam_ci.role_arn
  description = "GitHub Actions OIDC CI role ARN."
}

