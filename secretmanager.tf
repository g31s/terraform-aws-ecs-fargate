/* 
Module: ECS-Fargate-Appmesh
Version: 1.0.6

This file will create following:
  - create secrets 
*/

resource "aws_secretsmanager_secret" "main" {
  count       = length(var.secrets)
  name        = "${var.env}-${var.secrets[count.index]}"
  tags        = var.tags
}