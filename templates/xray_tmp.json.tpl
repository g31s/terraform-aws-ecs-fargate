,{
  "name": "xray-daemon",
  "image": "amazon/aws-xray-daemon",
  "memoryReservation": 256,
  "portMappings" : [
    { 
      "hostPort": 2000,
      "containerPort": 2000,
      "protocol": "udp"
    }
  ]
}