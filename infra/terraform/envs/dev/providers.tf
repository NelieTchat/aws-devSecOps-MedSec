variable "region" {
  type    = string
  default = "us-west-2"
}

provider "aws" {
  region = var.region
}
