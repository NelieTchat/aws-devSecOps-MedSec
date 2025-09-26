variable "name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Enable vulnerability scan on push"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the repository"
}

variable "force_delete" {
  type        = bool
  default     = false
  description = "Allow repo deletion even if images exist (use true in dev only)."
}
