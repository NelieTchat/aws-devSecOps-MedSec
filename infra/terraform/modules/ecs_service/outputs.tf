output "service_name" {
  value       = aws_ecs_service.svc.name
  description = "Deployed ECS service name."
}

output "taskdef_arn" {
  value       = aws_ecs_task_definition.task.arn
  description = "Task definition ARN."
}
