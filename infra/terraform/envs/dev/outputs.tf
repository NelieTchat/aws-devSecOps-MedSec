output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "azs" {
  value = module.network.azs
}

output "ecr_repo_url" {
  value = module.ecr_portal.repository_url
}

output "ci_role_arn" {
  value = module.iam_ci.role_arn
}
