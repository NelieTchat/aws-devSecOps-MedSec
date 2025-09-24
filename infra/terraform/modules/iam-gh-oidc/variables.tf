variable "name" {
  type        = string
  description = "Prefix for IAM resources (e.g., medsec-dev-ci)"
}

variable "repo" {
  type        = string
  description = "GitHub org/repo (e.g., ORG/REPO)"
}

variable "branch" {
  type        = string
  default     = "dev"
  description = "Branch allowed to assume the role"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all IAM resources"
}
