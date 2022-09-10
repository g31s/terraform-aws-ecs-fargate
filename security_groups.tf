/*
Module: ECS-Fargate-Appmesh
Version: 2.0.0

This file will create:
  - security groups to attach to ecs tasks and allow permission from private or public subnet.
*/

// traffic to the ECS cluster should only come from the LB
resource "aws_security_group" "ecs_tasks" {
  // add name
  name = "${var.prefix}-${var.env}-${var.app_name}-ecs-tasks-security-group"
  // add description
  description = "Allow inbound access from the private subnets for appmesh services. Allow inbound access from lb if virtual_gateway_arn is not none"
  // set vpc_id
  vpc_id = var.vpc.vpc_id

  // incoming tcp port open for fargate services
  ingress {
    description = "enable incomming traffic to ecs fargate services. Other than virtual gateway only private subnets allowed"
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = var.virtual_gateway_arn == "none" ? var.vpc.private_subnets_cidr_blocks : var.vpc.public_subnets_cidr_blocks
  }

  // fargate containers can access anything over the Internet. 
  // this is not the best idea because of SSRF attacks.
  egress {
    description = "out going traffic from appmesh services. by default only vpc cidr is set"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = length(var.egress_cidr_blocks) != 0 ? var.egress_cidr_blocks : [var.vpc.vpc_cidr_block]
  }

  // add tags
  tags = var.tags
}