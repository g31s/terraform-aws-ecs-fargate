{
    "widgets": [
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "${service_name}", "ClusterName", "${cluster_name}" ]
                ],
                "region": "${region}",
                "title": "ECS-CPUUtilization"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": true,
                "metrics": [
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "${service_name}", "ClusterName", "${cluster_name}" ]
                ],
                "region": "${region}",
                "period": 300,
                "title": "ECS-MemoryUtilization"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Logs", "IncomingLogEvents", "LogGroupName", "${loggroupname}" ]
                ],
                "region": "${region}",
                "title": "FargateService-IncomingLogEvents"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "singleValue",
                "stacked": false,
                "metrics": [
                    [ "AWS/Usage", "ResourceCount", "Type", "Resource", "Resource", "OnDemand", "Service", "Fargate", "Class", "None" ]
                ],
                "region": "${region}",
                "period": 300,
                "title": "Fargate-ResourceCount"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "pie",
                "metrics": [
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "${service_name}", "ClusterName", "${cluster_name}" ],
                    [ ".", "CPUUtilization", ".", ".", ".", "." ]
                ],
                "region": "${region}",
                "title": "ECS-Utilization"
            }
        }
    ]
}