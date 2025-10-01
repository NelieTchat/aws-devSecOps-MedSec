output "service_name" {
  value       = aws_ecs_service.svc.name
  description = "Deployed ECS service name."
}

output "taskdef_arn" {
  value       = aws_ecs_task_definition.task.arn
  description = "Task definition ARN."
}

output "name" {
  value       = aws_ecs_service.svc.name
  description = "ECS service name."
}

output "service_id" {
  value       = aws_ecs_service.svc.id
  description = "ECS service ID."
}
