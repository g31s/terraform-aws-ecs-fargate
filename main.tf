/* 
Module: ECS-Fargate-Appmesh
Version: 2.0.0

This file will create following:
  - aws ecs fargate cluster
  - ecs task definition
  - ecs service
*/

locals {
  env = concat(var.secrets, var.parameters)
}

// create aws_ecs_cluster with input name
resource "aws_ecs_cluster" "main" {
  // set name for ecs cluster
  name = "${var.prefix}-${var.env}-${var.app_name}-cluster"

  // enable container insights
  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }
  // set tags for cluster
  tags = var.tags
}

// creating secret manager json defined in: ./templates/env_tmp.json.tpl
data "template_file" "env_tmp" {
  // run as many times as secrets in variables
  count  = length(local.env)
  // set temp file path
  template  = file("${path.module}/templates/env_tmp.json.tpl")
  vars      = { 
    name     = element(local.env.*.name,count.index)
    arn      = element(local.env.*.arn,count.index)
  }  
}

// creating port mapping json defined in: ./templates/portmappings_tmp.json.tpl
data "template_file" "portmapping" {
  // run as many times as secrets in variables
  count  = length(var.extra_ports)
  // set temp file path
  template  = file("${path.module}/templates/portmappings_tmp.json.tpl")
  vars      = { 
    port      = element(var.extra_ports,count.index)
  }  
}

// creating xray json defined in: ./templates/xray_tmp.json.tpl
data "template_file" "xray" {
  // set temp file path
  template  = file("${path.module}/templates/xray_tmp.json.tpl")
}


// template to run the containers
data "template_file" "service_tmp" {
  // get template file from templates folder
  template  = var.virtual_gateway_arn == "none" ? file("${path.module}/templates/service_tmp.json.tpl") : file("${path.module}/templates/envoy_proxy.json.tpl")
  // variables for template
  vars      = { 
    // set container image provided by user or ecr url
    app_image           = var.app_image == "none" ? (var.virtual_gateway != "none" ? "" : aws_ecr_repository.ecr_repo[0].repository_url) : var.app_image
    extra_ports         = join("", data.template_file.portmapping.*.rendered)
    app_port            = var.app_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.region
    prefix              = var.prefix
    app_name            = var.app_name
    env                 = var.env
    envoy_proxy_image   = var.envoy_proxy_image
    mesh_name           = var.appmesh.name
    virtual_gateway_arn = var.virtual_gateway_arn
    virtual_node_arn    = var.aws_appmesh_virtual_node_arn
    secrets             = join(",", data.template_file.env_tmp.*.rendered)
    xray                = var.xray ? data.template_file.xray.rendered : ""
  }
}

// task definition for fargate cluster
resource "aws_ecs_task_definition" "main" {
  // family name
  family                    = "${var.prefix}-${var.env}-${var.app_name}-family"
  // render task template to definition
  container_definitions     = data.template_file.service_tmp.rendered
  // type of service is fargate
  requires_compatibilities  = ["FARGATE"]
  // set network mode to awsvpc
  network_mode              = "awsvpc"
  // set cpu for services 
  cpu                       = var.fargate_cpu
  // set memory for service
  memory                    = var.fargate_memory

  task_role_arn             = aws_iam_role.ecs_task_execution_role.arn
  // attach a role to definition described in role.tf
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn

  // add envoy proxy to task definition
  dynamic "proxy_configuration" {
    for_each = var.virtual_gateway == "none" ? [1] : []
      content {
          // container name
          container_name     = "envoy"
          // type of container
          type               = "APPMESH"
          // properties for proxy
          properties         = {
            AppPorts         = var.app_port
            EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
            IgnoredUID       = "1337"
            ProxyEgressPort  = 15001
            ProxyIngressPort = 15000
          }
    }
  }

  // add tags 
  tags = var.tags
}

// ecs fargate service
resource "aws_ecs_service" "main" {
  // set a name for service
  name            = "${var.prefix}-${var.env}-${var.app_name}-service"
  // add service to cluster
  cluster         = aws_ecs_cluster.main.id
  // add task definition 
  task_definition = aws_ecs_task_definition.main.id
  // set the desired count
  desired_count   = var.min_task_count
  // set launch type
  launch_type     = "FARGATE"

  // don't let outsider change task definition.
  lifecycle {
    ignore_changes = [task_definition]
  }

  // set the security groups and don't assign public ip
  network_configuration {
    // set the security group to service defined in security.tf
    // set security group if alb set to true in module variables
    security_groups   = [aws_security_group.ecs_tasks.id]
    // service can autoscale in private subnet
    subnets           = var.vpc.private_subnets
    // no public ip assigned will use loadbalancer
    assign_public_ip  = false
  }

  // add load balancer if virtual gateway is set
  dynamic "load_balancer" {
    for_each = var.virtual_gateway == "none" ? [] : [1]
      content {
        target_group_arn = aws_lb_target_group.main[0].id
        container_name   = "envoy"
        container_port   = var.app_port
      }
  }

  // register the containers running to cloudmap discovery
  service_registries {
    registry_arn = var.cloudmap_service.arn
  }

  // add tags 
  tags = var.tags
}