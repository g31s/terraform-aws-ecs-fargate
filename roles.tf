/*
Module: ECS-Fargate-Appmesh
Version: 1.2.7

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

resource "aws_iam_policy" "secrets_policy" {
  name        = "${var.prefix}-${var.env}-${var.app_name}-secrets-policy"
  path        = "/"
  description = "Defined policy to access secrets from secret manager"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
        Effect   = "Allow"
        Resource = var.secrets.*.arn
      },
    ]
  })
}

// to attach the secret manager policy
resource "aws_iam_role_policy_attachment" "sm-policy-attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

resource "aws_iam_policy" "parameters_policy" {
  name        = "${var.prefix}-${var.env}-${var.app_name}-parameters-policy"
  path        = "/"
  description = "Defined policy to access parameters from parameter store"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                "ssm:GetParameters",
                "ssm:DescribeParameters"
            ],
        Effect   = "Allow"
        Resource = var.parameters.*.arn
      },
    ]
  })
}

// to attach the secret manager policy
resource "aws_iam_role_policy_attachment" "ps-policy-attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.parameters_policy.arn
}

// add module provided policies
resource "aws_iam_role_policy_attachment" "module-provided-policies" {
  count      = length(var.policy_arn_attachments) == 0 ? 0 : length(var.policy_arn_attachments)
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = count.index
}
