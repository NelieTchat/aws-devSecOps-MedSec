variable "name" {
  type        = string
  description = "ECS cluster name."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the cluster."
}
