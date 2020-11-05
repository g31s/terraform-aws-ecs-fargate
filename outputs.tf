/* 
Module: ECS-Fargate-APPMESH
Version: 1.0.0

This file defines the output variables for this module
*/

// ECS output variables
output "ecs_cluster_arn" {
  description = "ECS cluster arn"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_arn" {
  description = "ECS service arn"
  value = aws_ecs_service.main.id
}

// ECR output variables
output "ecr_repo_url" {
  description = "ECR repo url"
  value       = length(aws_ecr_repository.ecr_repo) == 1 ? aws_ecr_repository.ecr_repo[0].repository_url : ""
}

output "ecr_repo_name" {
  description = "ECR repo name"
  value       = length(aws_ecr_repository.ecr_repo) == 1 ? aws_ecr_repository.ecr_repo[0].repository_url : ""
}

// load balancer variables
output "nlb_arn" {
  value = var.virtual_gateway == "none" ? "" : aws_lb.main[0].arn
}

output "target_group_arn" {
  value = var.virtual_gateway == "none" ? "" : aws_lb_target_group.main[0].arn
}