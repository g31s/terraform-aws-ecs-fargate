[
  {
    "name": "envoy",
    "image": "${envoy_proxy_image}",
    "essential": true,
    "networkMode": "awsvpc",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "environment": [
      {
        "name": "APPMESH_VIRTUAL_NODE_NAME",
        "value": "mesh/${mesh_name}/virtualGateway/${virtual_gateway}"
      },
      { "name" : "AWS_XRAY_DAEMON_ADDRESS", "value" : "xray-daemon:2000" }
    ],
    "portMappings": [
      {
        "hostPort": ${app_port},
        "containerPort": ${app_port}
      },
      {
        "hostPort": 9901,
        "protocol": "tcp",
        "containerPort": 9901
      }
      ${extra_ports}
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
        "awslogs-stream-prefix": "envoy${app_name}"
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