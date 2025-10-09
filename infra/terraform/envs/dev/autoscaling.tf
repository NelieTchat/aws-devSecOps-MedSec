########################################
# ECS Service Auto Scaling (dev)
########################################

# Tunables (or move to variables.tf if you prefer)
locals {
  svc_min_capacity = 1     # keep 1 task so TG is healthy
  svc_max_capacity = 4
  cpu_target_pct   = 50    # target CPU per task
  rps_per_target   = 100   # ALB requests/target threshold
}

# Register the service with Application Auto Scaling
resource "aws_appautoscaling_target" "ecs_desired_count" {
  max_capacity       = local.svc_max_capacity
  min_capacity       = local.svc_min_capacity
  resource_id        = "service/${module.ecs_cluster.name}/${module.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [module.ecs_service]
}

# Target-tracking on average CPU
resource "aws_appautoscaling_policy" "ecs_cpu_target" {
  name               = "cpu-target-${module.ecs_service.name}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_desired_count.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_desired_count.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_desired_count.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = local.cpu_target_pct
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

  depends_on = [aws_appautoscaling_target.ecs_desired_count]
}

# Target-tracking on ALB Requests/Target
resource "aws_appautoscaling_policy" "ecs_alb_rps" {
  name               = "rps-target-${module.ecs_service.name}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_desired_count.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_desired_count.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_desired_count.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = local.rps_per_target

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      # Format required by AWS: app/<ALB-ARN-SUFFIX>/targetgroup/<TG-ARN-SUFFIX>
      resource_label = "${module.alb.alb_arn_suffix}/${module.alb.tg_arn_suffix}"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

  depends_on = [aws_appautoscaling_target.ecs_desired_count]
}
