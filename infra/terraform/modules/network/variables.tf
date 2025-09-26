variable "name" {
  type        = string
  description = "Prefix for Name tags (e.g., medsec-dev)."
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block, e.g., 10.0.0.0/16."
}

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of AZs to spread private subnets across."
}

variable "subnet_newbits" {
  type        = number
  default     = 8
  description = "Newbits for private subnet sizing (8 => /24 from a /16)."
}

variable "enable_public_subnets" {
  type        = bool
  default     = true
  description = "Create public subnets + IGW for ALB."
}

variable "public_subnet_newbits" {
  type        = number
  default     = 8
  description = "Newbits for public subnets (8 => /24 from a /16)."
}

variable "enable_endpoints" {
  type        = bool
  default     = true
  description = "Create VPC endpoints for private access to AWS services."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Baseline tags applied to all resources."
}
