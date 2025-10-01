# ########################################
# # CloudWatch Alarms (dev)
# ########################################

# # High ECS CPU for the service (sustained >80% for 5 minutes)
# resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
#   alarm_name          = "medsec-dev-portal-cpu-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 5
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80

#   dimensions = {
#     ClusterName = module.ecs_cluster.name
#     ServiceName = module.ecs_service.name
#   }

#   alarm_description  = "ECS service CPU >80% for 5m"
#   treat_missing_data = "missing"
# }

# # ALB 5xx surge (>= 5 errors in 5 minutes)
# resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
#   alarm_name          = "medsec-dev-alb-5xx"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 1
#   metric_name         = "HTTPCode_ELB_5XX_Count"
#   namespace           = "AWS/ApplicationELB"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = 5

#   # Dimensions by ALB and Target Group; the suffix form is most robust
#   dimensions = {
#     LoadBalancer = aws_lb_dummy_ref.alb_arn_suffix
#   }

#   alarm_description  = "ALB 5xx >= 5 in 5m"
#   treat_missing_data = "notBreaching"
# }

# # Helper to feed ALB ARN suffix to the alarm without changing your module:
# # (If your alb module already outputs alb_arn_suffix, use that instead and delete this data block.)
# data "aws_lb" "alb_lookup" {
#   arn = module.alb.alb_arn # If you don't export alb_arn, swap for: aws_lb_dummy_ref.alb_arn
# }

# # If your alb module does not yet export arn/arn_suffix, add outputs like:
# # output "alb_arn"        { value = aws_lb.alb.arn }
# # output "alb_arn_suffix" { value = aws_lb.alb.arn_suffix }

# # A local 'bridge' so the alarm can read the suffix cleanly
# locals {
#   alb_arn_suffix = replace(data.aws_lb.alb_lookup.arn, "arn:aws:elasticloadbalancing:us-west-2:${var_account_id}:", "")
# }

# # If your module already has alb_arn_suffix, use this instead and remove the data+local above:
# # dimensions = { LoadBalancer = module.alb.alb_arn_suffix }
