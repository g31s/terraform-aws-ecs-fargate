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


resource "aws_service_discovery_service" "app" {
  name = "app.test.local"

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
  name = "app-app-mesh"
  spec {
    egress_filter {
      type = "DROP_ALL"
    }
  }
}

resource "aws_appmesh_virtual_node" "app" {
  name      = "app"
  mesh_name = aws_appmesh_mesh.main.name
  spec {   
    listener {
      port_mapping {
        port     = "80"
        protocol = "http"
      }
      health_check {
        protocol            = "http"
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }

    }
    service_discovery {
      aws_cloud_map {
        service_name   = aws_service_discovery_service.app.name
        namespace_name = aws_service_discovery_private_dns_namespace.main.name
      }
    }

  }

}

resource "aws_appmesh_virtual_router" "app" {
  name      = "app-router"
  mesh_name = aws_appmesh_mesh.main.name
  spec {
    listener {
      port_mapping {
        port     = "80"
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_route" "app" {
  name                = "app-route"
  mesh_name           = aws_appmesh_mesh.main.name
  virtual_router_name = aws_appmesh_virtual_router.app.name

 spec {
    http_route {
      match {
        prefix = "/"
      }

      retry_policy {
        http_retry_events = [
          "server-error",
        ]
        max_retries = 1

        per_retry_timeout {
          unit  = "s"
          value = 15
        }
      }


      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.app.name
          weight       = 1
        }

      }
    }
  }
}


resource "aws_appmesh_virtual_service" "app" {
  name      = "app.test.local"
  mesh_name = aws_appmesh_mesh.main.name
  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.app.name
      }
    }
  }
}

module "test" {
  source            = "./../ecs-fargate"
  region            = "us-east-1"
  app_name          = "app"
  app_port          = "80"
  env               = "dev"
  vpc               = module.vpc
  app_image         = "nginx:1.13.9-alpine"
  cloudmap_service  = aws_service_discovery_service.app
  aws_appmesh_virtual_node = aws_appmesh_virtual_node.app.name
  appmesh           = aws_appmesh_mesh.main
}