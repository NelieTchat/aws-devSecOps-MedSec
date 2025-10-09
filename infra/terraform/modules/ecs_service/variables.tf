variable "name" {
  type        = string
  description = "Service and task family name."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "If true, tasks receive a public IP (useful for dev without NAT/VPC endpoints)."
}

variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the service ENIs."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the service ENIs."
}

variable "container_image" {
  type        = string
  description = "Image to run (e.g., <acct>.dkr.ecr.region.amazonaws.com/repo:tag)."
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Container port exposed by the app."
}

variable "task_role_arn" {
  type        = string
  description = "Task role ARN for app containers."
}

variable "exec_role_arn" {
  type        = string
  description = "Execution role ARN for pulling from ECR and writing logs."
}

variable "cpu" {
  type        = number
  default     = 256
  description = "Task CPU units (e.g., 256 = 0.25 vCPU)."
}

variable "memory" {
  type        = number
  default     = 512
  description = "Task memory (MiB)."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of tasks."
}

variable "target_group_arn" {
  type        = string
  default     = ""
  description = "ALB target group ARN (if set, service registers targets)."
}

variable "container_name" {
  type        = string
  default     = "app"
  description = "Container name used in the task definition (for ALB binding)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to resources."
}

variable "enable_container_healthcheck" {
  type        = bool
  default     = false
  description = "Enable container-level healthcheck (defaults to false for stability)."
}
