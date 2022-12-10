[
  {
    "name": "${prefix}-${env}-${app_name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${prefix}-${env}-${app_name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "hostPort": ${app_port},
        "containerPort": ${app_port}
      }
      ${extra_ports}
    ],
    "dependsOn": [
      {
        "containerName": "envoy",
        "condition": "HEALTHY"
      }
    ],
    "ulimits": [
      {
        "softLimit": 50000,
        "hardLimit": 50000,
        "name": "nofile"
      }
    ],
    "environment":
    [
      { "name" : "AWS_XRAY_DAEMON_ADDRESS", "value" : "xray-daemon:2000" },
      { "name" : "ENV", "value" : "${env}" }
    ],
    "secrets": [${secrets}],
    "runtimePlatform": {
        "operatingSystemFamily": "LINUX"
    },
    "requiresCompatibilities": [ 
       "FARGATE" 
    ]
  },
  {
    "name": "envoy",
    "image": "${envoy_proxy_image}",
    "essential": true,
    "networkMode": "awsvpc",
    "memoryReservation": 256,
    "environment": [
      {
        "name": "APPMESH_RESOURCE_ARN",
        "value": "${virtual_node_arn}"
      },
      { "name" : "AWS_XRAY_DAEMON_ADDRESS", "value" : "xray-daemon:2000" }
    ],  
    "portMappings": [
        {
          "hostPort": 9901,
          "protocol": "tcp",
          "containerPort": 9901
        }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ],
      "startPeriod": 10,
      "interval": 5,
      "timeout": 2,
      "retries": 3
    },
    "user": "1337",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${prefix}-${env}-${app_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs-envoy-${app_name}"
      }
    },
    "ulimits": [
      {
        "softLimit": 15000,
        "hardLimit": 15000,
        "name": "nofile"
      }
    ]
  }
  ${xray}
]