/*
Module: ECS-Fargate-Appmesh
Version: 2.0.0

This file will create following for fargate service:
  - log group 
  - log stream
*/

// set up cloudwatch group and retain logs for 90 days
resource "aws_cloudwatch_log_group" "fargate_service_log_group" {
  // set name
  name = "/ecs/${var.prefix}-${var.env}-${var.app_name}"
  // retain logs for 90 days
  retention_in_days = 90

  // logs enc key
  kms_key_id = var.cloudwatch_kms_key_arn != "" ? var.cloudwatch_kms_key_arn : ""

  // add tags
  tags = var.tags
}

// set up log stream and retain logs for 90 days
resource "aws_cloudwatch_log_stream" "fargate_service_log_stream" {
  //set name
  name = "${var.prefix}-${var.env}-${var.app_name}-log-stream"
  // log group name
  log_group_name = aws_cloudwatch_log_group.fargate_service_log_group.name
}