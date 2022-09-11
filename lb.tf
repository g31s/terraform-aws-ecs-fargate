/*
Module: ECS-Fargate-Appmesh
Version: 2.0.0

This file will create following:
  - elastic load balancer
  - target group
  - lb listeners for port 80,443
*/

// add application load balancer
resource "aws_lb" "main" {
  // create lb if virtual_gateway is enabled
  count = var.virtual_gateway_arn == "none" ? 0 : 1
  // name for lb
  name = "${var.env}-${var.app_name}-lb"
  // putting it in public subnet
  subnets = var.vpc.public_subnets
  // type of load balancer
  load_balancer_type = "network"

  // add tags
  tags = var.tags
}

// create target group for fargate service
resource "aws_lb_target_group" "main" {
  // create lb if virtual_gateway is enabled
  count = var.virtual_gateway_arn == "none" ? 0 : 1
  // set name for target group
  name = "${var.prefix}-${var.env}-${var.app_name}-tg"
  // set port for lb
  port = 80
  // set protocol 
  protocol = "TCP"
  // add vpc id
  vpc_id = var.vpc.vpc_id
  // set target type is ip
  target_type = "ip"

  // stickiness of cookies
  stickiness {
    type    = "source_ip"
    enabled = var.nlb_stickiness
  }

  // add tags
  tags       = var.tags
  depends_on = [aws_lb.main]
}

/// http listener if no certificate provided
resource "aws_lb_listener" "front_end_http_without_cert" {
  // create lb if virtual_gateway is enabled
  count = var.virtual_gateway_arn == "none" ? 0 : 1
  // set lb arn to listener
  load_balancer_arn = aws_lb.main[count.index].id
  // set port
  port = 80
  // set protocol
  protocol = "TCP"
  default_action {
    // type of action
    type = "forward"
    // add target arn
    target_group_arn = aws_lb_target_group.main[count.index].id

  }
}

// redirect all traffic from lb to target groups
resource "aws_lb_listener" "front_end_https" {
  // create only if certificate is provided
  count = (var.virtual_gateway_arn != "none" && var.certificate) ? 1 : 0
  // set lb arn to listener
  load_balancer_arn = aws_lb.main[count.index].id
  // set port
  port = 443
  // set protocol
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  protocol   = "TCP"
  // set the certificate defined in variable
  certificate_arn = var.certificate_arn
  // set the default action
  default_action {
    // add target arn
    target_group_arn = aws_lb_target_group.main[count.index].id
    // type of action
    type = "forward"
  }
}