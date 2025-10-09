variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region to deploy resources into"
}

provider "aws" {
  region = var.region
}
