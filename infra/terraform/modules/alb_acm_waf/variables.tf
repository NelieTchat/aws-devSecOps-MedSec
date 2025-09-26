variable "name" {
  type        = string
  description = "Name prefix for ALB resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
}

variable "https" {
  type        = bool
  default     = false
  description = "Enable HTTPS listener"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN (required if https = true)"
}

variable "waf_enabled" {
  type        = bool
  default     = false
  description = "Enable WAF and associate with the ALB"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply"
}
