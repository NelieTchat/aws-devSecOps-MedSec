########################################
# Network (private + public for ALB)
########################################
module "network" {
  source                = "../../modules/network"
  name                  = "medsec-dev"
  cidr_block            = var.vpc_cidr
  az_count              = var.az_count
  subnet_newbits        = 8
  enable_endpoints      = true
  enable_public_subnets = true
  public_subnet_newbits = 8
  tags                  = local.common_tags
}

########################################
# ECR (dev repo; force delete enabled)
########################################
module "ecr_portal" {
  source       = "../../modules/ecr"
  name         = "medsec-portal-dev"
  force_delete = true
  tags         = local.common_tags
}

########################################
# ECS Cluster
########################################
module "ecs_cluster" {
  source = "../../modules/ecs_cluster"
  name   = "medsec-dev-cluster"
  tags   = local.common_tags
}

########################################
# IAM for Task / Execution roles
########################################
module "iam_task" {
  source               = "../../modules/iam_task"
  name                 = "medsec-dev"
  allow_secretsmanager = true
  tags                 = local.common_tags
}

########################################
# Public ALB (HTTP now; HTTPS later)
########################################
module "alb" {
  source          = "../../modules/alb_acm_waf"
  name            = "medsec-dev"
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.public_subnet_ids
  https           = false # flip to true when you add a cert
  certificate_arn = ""    # ACM ARN when ready
  waf_enabled     = false
  tags            = local.common_tags
}

########################################
# SG for ECS service (allow only from ALB)
########################################
resource "aws_security_group" "svc_sg" {
  name        = "medsec-dev-svc-sg"
  vpc_id      = module.network.vpc_id
  description = "Allow ALB to reach service on 8080"

  ingress {
    description     = "ALB to service"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [module.alb.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

########################################
# ECS Service (wires to ALB TG)
########################################
module "ecs_service" {
  source             = "../../modules/ecs_service"
  name               = "medsec-dev-portal"
  cluster_arn        = module.ecs_cluster.cluster_arn
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [aws_security_group.svc_sg.id]

  container_image = format("%s:%s", module.ecr_portal.repository_url, var.image_tag)
  container_name  = "medsec-dev-portal"
  container_port  = 8080

  task_role_arn = module.iam_task.task_role_arn
  exec_role_arn = module.iam_task.exec_role_arn

  cpu           = 256
  memory        = 512
  desired_count = 1

  # ALB binding
  target_group_arn = module.alb.tg_arn

  tags = local.common_tags
}

module "iam_ci" {
  source = "../../modules/iam-gh-oidc"
  name   = "medsec-dev-ci"
  repo   = "NelieTchat/aws-devSecOps-MedSec"
  branch = "dev"
  tags   = local.common_tags
}
