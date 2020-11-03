/* 
Module: ECS-Fargate-Appmesh
Version: 0.0.1

This file will create following:
  - elastic contaienr registry to store app docker image
*/

// create ecr registry
resource "aws_ecr_repository" "ecr_repo" {
  // run only if app image is not provided and don't if virtual gateway is provided
  count = (var.app_image != "none" || var.virtual_gateway != "none") ? 0 : 1
  // name can be in lower case only
  name                 = "${var.prefix}-${var.env}-${var.app_name}"
  image_tag_mutability = "MUTABLE"

  // scan image configuration
  image_scanning_configuration {
    scan_on_push = true
  }
  
  // add tags
  tags = var.tags
}