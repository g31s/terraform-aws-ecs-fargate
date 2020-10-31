/*
Module: ECS-Fargate-Appmesh
Version: 0.0.1

This file will create:
  - security groups attach to ecs tasks and allow permission from private or public subnet.
*/

// traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  // add name
  name        = "${var.prefix}-${var.env}-${var.app_name}-ecs-tasks-security-group"
  // add description
  description = "Allow inbound access from the private subnets for appmesh services. Allow inbound access from lb if virtual_gateway is not none"
  // set vpc_id
  vpc_id      = var.vpc.vpc_id

  // incoming tcp port open for fargate services
  ingress {
    protocol            = "tcp"
    from_port           = var.app_port
    to_port             = var.app_port
    cidr_blocks         = var.virtual_gateway == "none" ? var.vpc.private_subnets_cidr_blocks : var.vpc.public_subnets_cidr_blocks
  }

  // fargate containers can access anything over the internet. 
  // this is not the best idea because of SSRF attacks.
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  // add tagss
  tags = var.tags
}