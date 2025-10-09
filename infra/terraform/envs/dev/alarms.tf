########################################
# CloudWatch Alarms + Dashboard (dev)
########################################

# --- ECS CPU high (avg >80% 5m) ---
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${local.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "missing"
  alarm_description   = "ECS service CPU >80% (5m)"

  dimensions = {
    ClusterName = module.ecs_cluster.name
    ServiceName = module.ecs_service.name
  }

  tags = local.common_tags
}

# --- ALB 5xx burst (>= 5 in 5m) ---
resource "aws_cloudwatch_metric_alarm" "alb_5xx_burst" {
  alarm_name          = "${local.name}-alb-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_description   = "ALB 5xx >=5 in 5m"

  dimensions = {
    LoadBalancer = module.alb.alb_arn_suffix
  }

  tags = local.common_tags
}

# --- Simple CW Dashboard (ECS CPU + ALB 5xx) ---
resource "aws_cloudwatch_dashboard" "service_dashboard" {
  dashboard_name = "${local.name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "properties": {
          "title": "ECS CPU Utilization",
          "metrics": [
            ["AWS/ECS", "CPUUtilization",
             "ClusterName", "${module.ecs_cluster.name}",
             "ServiceName", "${module.ecs_service.name}"]
          ],
          "stat": "Average",
          "period": 60,
          "region": "${var.region}"
        }
      },
      {
        "type": "metric",
        "properties": {
          "title": "ALB 5xx (Sum)",
          "metrics": [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count",
             "LoadBalancer", "${module.alb.alb_arn_suffix}", { "stat": "Sum" }]
          ],
          "period": 300,
          "region": "${var.region}"
        }
      }
    ]
  })

}
