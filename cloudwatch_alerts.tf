/* 
Module: ECS-Fargate-Appmesh
Version: 1.0.0

This file will create following cloudwatch alerts:
  - when fargate container reach 80% or above cpu usage
  - when fargate container has 60% or below cpu usage
Actions:
  - add new container on high cpu usage alert
  - remove container on low cpu usage alert
*/

// cloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  // set alarm name 
  alarm_name = "${var.prefix}-${var.env}-${var.app_name}-cpu-utilization-high"
  // when cpu usage is greater or equal to threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  // evaluate this alert every 2 seconds
  evaluation_periods = "2"
  // alert set for CPU utilization
  metric_name = "CPUUtilization"
  // name space for aws/ecs
  namespace = "AWS/ECS"
  // trigger alert when usage is equal or above 80% for 1 min. 
  period = "60"
  // statistic type
  statistic = "Average"
  // trigger when cpu at 80% or above for 1 min.
  threshold = "80"

  // dimensions for alert
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  // run scaling up policy when this alert gets triggered
  alarm_actions = [aws_appautoscaling_policy.up.arn]

  // add tags
  tags = var.tags
}

// cloudWatch alarm that triggers the auto scaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  // set alert name
  alarm_name = "${var.prefix}-${var.env}-${var.app_name}-cpu-utilization-low"
  // when cpu usage is below or equal to threshold
  comparison_operator = "LessThanOrEqualToThreshold"
  // evaluate this alert every 2 seconds
  evaluation_periods = "2"
  // alert set for CPU utilization
  metric_name = "CPUUtilization"
  // name space for aws/ecs
  namespace = "AWS/ECS"
  // trigger alert when usage is equal or below 60% for 1 min. 
  period = "60"
  // statistic type
  statistic = "Average"
  // trigger when cpu at 60% or below for 1 min.
  threshold = "60"

  // dimensions for alert
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  // run scaling up policy when this alert gets triggered
  alarm_actions = [aws_appautoscaling_policy.down.arn]

  // add tags
  tags = var.tags
}