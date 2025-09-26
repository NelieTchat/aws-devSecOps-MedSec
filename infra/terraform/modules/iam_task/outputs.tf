output "task_role_arn" {
  value       = aws_iam_role.task_role.arn
  description = "Task role ARN."
}

output "exec_role_arn" {
  value       = aws_iam_role.exec_role.arn
  description = "Execution role ARN."
}
