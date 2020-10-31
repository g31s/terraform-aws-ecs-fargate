/* 
Module: ECS-Fargate-Appmesh
Version: 0.0.1

This file will create following:
  - elastic contaienr registory to store app docker image
*/

// create ecr registory
resource "aws_ecr_repository" "ecr_repo" {
  // run only if app image is not provided and don't if virutal gateway is provided
  count = (var.app_image != "none" || var.virtual_gateway != "none") ? 0 : 1
  // name can only by lowwer case.
  name                 = "${var.prefix}-${var.env}-${var.app_name}"
  image_tag_mutability = "MUTABLE"

  // scan image configuration
  image_scanning_configuration {
    scan_on_push = true
  }
  
  // add tags
  tags = var.tags
}