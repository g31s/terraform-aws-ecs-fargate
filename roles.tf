/*
Module: ECS-Fargate-Appmesh
Version: 0.0.1

This file will create:
  - IAM policy: to allow ecs tasks to assume role
  - IAM role: to assume role policy we defined
  - IAM role: to assume secret manager policy
  - IAM role: to assume appmesh envoy access 
*/

// ecs task execution role json data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  // version for policy
  version   = "2012-10-17"
  // state for policy to allow service to assume role
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

// ecs task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  // set name for role 
  name                = "${var.prefix}-${var.env}-${var.app_name}-ecs-task-execution-role"
  // attach policy to role 
  assume_role_policy  =  data.aws_iam_policy_document.ecs_task_execution_role.json

  // add tags
  tags   = var.tags
}

// ecs task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role        = aws_iam_role.ecs_task_execution_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


// ecs task allow appmesh permissions policy attachment
resource "aws_iam_role_policy_attachment" "ecs_appmesh_envoy_access_role" {
  role        = aws_iam_role.ecs_task_execution_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

// to attach the secret manager policy
resource "aws_iam_role_policy_attachment" "sm-policy-attach" {
  count  = length(var.secrets) == 0 ? 0 : 1
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}