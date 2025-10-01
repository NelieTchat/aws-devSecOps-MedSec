variable "name" {
  type        = string
  description = "Prefix for ALB-related resources (e.g., medsec-dev)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB and target group live."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."
}

variable "https" {
  type        = bool
  default     = false
  description = "Enable HTTPS listener and HTTP→HTTPS redirect."
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN (same region as the ALB)."
}

variable "waf_enabled" {
  type        = bool
  default     = false
  description = "Attach a regional WAF with AWS managed rules."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to ALB resources."
}
