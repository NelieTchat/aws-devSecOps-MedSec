resource "aws_ecs_cluster" "main" {
  name = var.name

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = merge(var.tags, { Name = var.name })
}
