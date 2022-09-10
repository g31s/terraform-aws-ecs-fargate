/* 
Module: ECS-Fargate-Appmesh
Version: 1.0.0

This file will create:
  - auto scaling target
  - auto scaling policy to add new containers
  - auto scaling policy to remove containers
*/

// auto scale target set for fargate service 
resource "aws_appautoscaling_target" "target" {
  // serice_namesapce
  service_namespace = "ecs"
  // resource id for fargate service
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  // scale dimension for service. set minimum to 1 and max to 10
  scalable_dimension = "ecs:service:DesiredCount"
  // minimum running services 
  min_capacity = var.min_task_count
  // maximun running services 
  max_capacity = var.max_task_count
}

// when to scale up tasks in fargate service
resource "aws_appautoscaling_policy" "up" {
  // name for policy
  name = "${var.prefix}-${var.env}-${var.app_name}-scale-up"
  // set service namespace
  service_namespace = "ecs"
  // set resource id from fargate service
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  // scale dimensions
  scalable_dimension = "ecs:service:DesiredCount"

  // scale up by 1 when cpu usage is above 80%
  step_scaling_policy_configuration {
    // change in capacity when reach 60% cpu usage. after 1 min
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    // add 1 more task when reach 80%
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  // create this resource when target is created
  depends_on = [aws_appautoscaling_target.target]
}

// when to scale down task in fargate service
resource "aws_appautoscaling_policy" "down" {
  // name for policy
  name = "${var.prefix}-${var.env}-${var.app_name}-scale-down"
  // set service namespace
  service_namespace = "ecs"
  // set resource id from fargate service
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  // scale dimensions
  scalable_dimension = "ecs:service:DesiredCount"

  // scale down by 1 when cpu usage is below 60%
  step_scaling_policy_configuration {
    // change in capacity when cpu usage below 60%. after 300 seconds
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    // remove 1 task when cpu usage below 60%
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  // create this resource when target is created
  depends_on = [aws_appautoscaling_target.target]
}