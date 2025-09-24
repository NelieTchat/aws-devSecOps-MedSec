module "network" {
  source           = "../../modules/network"
  name             = "medsec-dev"
  cidr_block       = var.vpc_cidr
  az_count         = var.az_count
  subnet_newbits   = 8
  enable_endpoints = true
  tags             = local.common_tags
}

module "ecr_portal" {
  source = "../../modules/ecr"

  name   = "medsec-portal-dev"
  tags   = local.common_tags
}

module "iam_ci" {
  source = "../../modules/iam-gh-oidc"
  name   = "medsec-dev-ci"
  repo   = "YOURORG/YOURREPO"   # must be your actual GitHub org/repo
  branch = "dev"
  tags   = local.common_tags
}
