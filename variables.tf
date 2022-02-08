/*
Module: ECS-Fargate-APPMESH
Version: 1.2.7

This file defines all the variables for this module.
Variables are divided into two sections:
  - Required variables
  - Optional variables
*/

//  -------------Module Variables(Required)---------------
// project variables
variable "region" {
  type        = string
  description = "region where to create resources"
}

variable "env" {
  type        = string
  description = "app deployment environment"
}

// app variables
variable "app_name" {
  type        = string
  description = "application name"
}

variable "app_port" {
  type        = string
  description = "app port to expose"
}

variable "appmesh" {
  description = "appmesh resource to create virtual node and service"
}

variable "cloudmap_service" {
  description = "register service in cloudmap"
}

variable "cw_dashboard" {
  type        = string
  description = "set to true to add cloudwatch dashboard"
  default     = "none"
}

// vpc variables
variable "vpc" {
  description = "vpc id to create resources"
}


// -------------General(optional)---------------
variable "prefix" {
  type        = string
  description = "project prefix added to all resources created"
  default     = "EFA"
}

variable "policy_arn_attachments" {
  type        = list(string)
  description = "list of  policies that needs to be attached"
  default     = []
}

// app variables
variable "app_image" {
  type = string
  description = "docker image or by default creates ECS repo"
  default = "none"
}

variable "min_task_count" {
  type        = number
  description = "minimum number of app containers running"
  default     = 1
}

variable "max_task_count" {
  type        = number
  description = "minimum number of app containers running"
  default     = 10
}

variable "extra_ports" {
  type        = list(string)
  description = "additional ports to expose. useful case: rabbitmq"
  default     = []
}

variable "secrets" {
  description = "allow fargate task access to secret manager secrets."
  default = []
}

variable "parameters" {
  description = "allow farget task to access parameter store"
  default = []
}

// appmesh variables
variable "aws_appmesh_virtual_node" {
  type = string
  description = "set appmesh virtual node"
  default = "none"
}

variable "virtual_gateway" {
  type = string
  description = "set appmesh virtual gateway"
  default = "none"
}

variable "envoy_proxy_image" {
  type        = string
  description = "app mesh image for all regions except me-south-1 and ap-east-1"
  default     = "840364872350.dkr.ecr.us-east-1.amazonaws.com/aws-appmesh-envoy:v1.17.2.0-prod"
}

// load balancer variables
variable "certificate" {
  type        = bool
  description = "create ceritificate resurces if value true"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "set to true to add ssl to alb"
  default     = "none"
}

variable "nlb_stickiness" {
  type = bool
  description = "enable stickiness for network load balancer"
  default = false
}

// Health check variables
variable "health_check" {
  type = bool
  description = "enable healthcheck for taget group"
  default = true
}

variable "health_check_timeout" {
  type        = number
  description = "set timeout for healthcheck in seconds"
  default     = 10
}

variable "health_check_path" {
  type        = string
  description = "set healthcheck path for instance"
  default     = "/"
}

// add xray to task definition
variable "xray" {
  type = bool
  description = "add xray daemon as sidecar"
  default = false
}

// tags
variable "tags" {
  type        = map(string)
  description = "tags to add to all resources created with this module"
  default     = {
    Terraform = "true"
    Module    = "ecs-fargate"  
  }
}

// -------------Fargate variables(optional)------------------

// fargate cluster Variables
variable "fargate_cpu" {
  type        = string
  description = "fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  type        = string
  description = "fargate instance memory to provision (in MiB)"
  default     = "2048"
}