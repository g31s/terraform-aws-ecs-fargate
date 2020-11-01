provider "aws" {
  region  = "us-east-1"
}

# creating VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.63.0" 

  name = "test_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]

  private_subnets = ["10.0.51.0/24","10.0.52.0/24"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
}

resource "aws_appmesh_mesh" "main" {
  name = "main-app-mesh"
  spec {
    egress_filter {
      type = "DROP_ALL"
    }
  }
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "test.local"
  description = "all services will be registered under this comman namespace"
  vpc         = module.vpc.vpc_id
}


resource "aws_service_discovery_service" "envoy_proxy" {
  name = "test-virtual-gateway.local"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }

}

resource "aws_appmesh_mesh" "main" {
  name = "test-app-mesh"
  spec {
    egress_filter {
      type = "DROP_ALL"
    }
  }
}


resource "aws_appmesh_virtual_gateway" "vgateway" {
  name      = "test-vg"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    listener {
      port_mapping {
        port     = 80
        protocol = "http"
      }

      health_check {
        port                = 80
        protocol            = "http"
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }

    }
  }
}

resource "aws_appmesh_gateway_route" "route" {
  name                 = "test-gateway-route"
  virtual_gateway_name = aws_appmesh_virtual_gateway.vgateway.name
  mesh_name            = aws_appmesh_mesh.main.name

  http_route {
    action {
      target {
        virtual_service {
          virtual_service_name = aws_appmesh_virtual_service.app.name
        }
      }
    }

    match {
      prefix = "/"
    }
  }
}

// add envoy proxy 
module "envoy-proxy" {
  source            = "./../ecs-fargate"
  region            = "us-east-1"
  app_name          = "test"
  app_port          = "80"
  env               = "dev"
  vpc               = module.vpc
  cloudmap_service  = aws_service_discovery_service.envoy_proxy
  appmesh           = aws_appmesh_mesh.main
  virtual_gateway   = "test-vg"
}