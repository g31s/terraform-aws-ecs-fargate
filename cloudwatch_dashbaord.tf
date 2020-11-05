/* 
Module: ECS-Fargate-Appmesh
Version: 1.0.0

This file will create following:
  - cloudwatch dashboard for app and virutal gateway
*/

data "template_file" "lb_dash_body" {
  template = file("${path.module}/templates/lb_dash_body.json.tpl")
  vars = {
    service_name  = aws_ecs_service.main.name
    cluster_name  = aws_ecs_cluster.main.name
    loggroupname  = aws_cloudwatch_log_group.fargate_service_log_group.name
    region        = var.region
    az_first      = "${var.region}a"
    az_second     = "${var.region}b"
    loadbalancer  = var.virtual_gateway == "none" ? "none" : "net/${aws_lb.main[0].name}/${split("/", aws_lb.main[0].arn)[3]}"
  }
}

data "template_file" "gen_dash_body" {
  template = file("${path.module}/templates/dash_body.json.tpl")
  vars = {
    service_name  = aws_ecs_service.main.name
    cluster_name  = aws_ecs_cluster.main.name
    loggroupname  = aws_cloudwatch_log_group.fargate_service_log_group.name
    region        = var.region
    az_first      = "${var.region}a"
    az_second     = "${var.region}b"
  }
}

resource "aws_cloudwatch_dashboard" "gen_dashboard" {
  count           = var.cw_dashboard == "none" ? 0 : 1
  dashboard_name  = "${var.env}-${var.app_name}-dashboard"
  dashboard_body  =  var.virtual_gateway == "none" ? data.template_file.gen_dash_body.rendered : data.template_file.lb_dash_body.rendered
}