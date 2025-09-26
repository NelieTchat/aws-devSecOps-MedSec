variable "name" {
  type        = string
  description = "Prefix for IAM roles/policies (e.g., medsec-dev)."
}

variable "allow_secretsmanager" {
  type        = bool
  default     = true
  description = "Attach a policy that allows reading from Secrets Manager."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to IAM resources."
}
