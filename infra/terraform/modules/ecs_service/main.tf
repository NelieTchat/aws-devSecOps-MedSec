resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name}"
  retention_in_days = 14
  tags              = merge(var.tags, { Name = "/ecs/${var.name}" })
}

# Optional container healthcheck toggle
locals {
  container_healthcheck = var.enable_container_healthcheck ? {
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  } : {}
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.exec_role_arn

  container_definitions = jsonencode([
    merge({
      name  = var.container_name
      image = var.container_image
      essential = true

      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = var.name
        }
      }
    }, local.container_healthcheck)
  ])

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_ecs_service" "svc" {
  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  tags = merge(var.tags, { Name = var.name })
}
