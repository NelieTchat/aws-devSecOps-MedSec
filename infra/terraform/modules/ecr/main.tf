resource "aws_ecr_repository" "repo" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
 
  encryption_configuration {
    encryption_type = "KMS" # AWS-managed KMS
  }

  force_delete = var.force_delete

  tags = merge(
    var.tags,
    { Name = "${var.name}-ecr" }
  )
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.repo.name
  policy     = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expire untagged images after 7 days",
      selection    = {
        tagStatus     = "untagged"
        countType     = "sinceImagePushed"
        countUnit     = "days"
        countNumber   = 7
      }
      action = { type = "expire" }
    }]
  })
}
