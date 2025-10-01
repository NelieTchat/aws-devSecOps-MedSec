output "cluster_arn" {
  value       = aws_ecs_cluster.main.arn
  description = "ECS cluster ARN."
}
output "name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS cluster name."
}
