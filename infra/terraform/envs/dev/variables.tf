variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for the VPC"
}

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of AZs for private subnets"
}

variable "image_tag" {
  type        = string
  description = "ECR image tag to deploy (e.g., dev-50ffcd9)."

}
