# Terraform AWS ECS Fargate Module

The module is developed to quickly implement fargate cluster for appmesh microservices or virtual gateway. Following are the features

## Features
- Appmesh 
- Cloudmap service
- Virtual Gateway envoy proxy with a load balancer
- Sidecars supported:
  - envoy proxy
  - aws xray
- Secret Manager
- Parameter Store
- Elastic container registry (ECR)
- Auto Scaling
- Cloudwatch Dashboard
- SSL cert on LB
- Cloudwatch Dashboard


## Security Recommendations
We suggest that you provide KMS keys for ECR and Cloudwatch encryption.

## Example
Following example creates fargate cluster for appmesh service
```
module "test" {
  source            		= "github.com/g31s/ecs-fargate"
  // project variables
  region            		= var.region
  vpc               		= "vpc object"
  env               		= "dev"
  // app variables
  app_name          		= "test"
  app_port          		= "80"
  cloudmap_service  		= "cloudmap service name"
  aws_appmesh_virtual_node 	= "appmesh virtual node name"
  appmesh           		= "appmesh object"
}
```
More examples: [Examples](./examples/)

## Input Variables
|   Variable  	              |    Required		  | 	 Default	| 	   Type	 	|	   Info	 	|    Example    |
| -------------               | ------------- 	| ------------- | ------------- | ------------- | ------------- |
| vpc 		              	    | 	    Y 		    | 	    -	 	     |	  object 	  | 	    -	 	|	module.vpc from terraform vpc module will be one example |
| region 	              	    | 	    Y 	     	| 	    -	        	|	  string 	| 	    -	 	|	"us-east-1" |
| env 		              	    | 	    Y 		    | 	    -	 	|	  string 	| 	    -	 	|	"dev" |
| app_name 	                  | 	    Y 		     | 	    -	 	|	  string 	| 	    -	 	|	"test" |
| app_port 	              	  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"80" |
| appmesh 	              	  | 	    Y 		| 	    -	 	|	  object 	| 	    -	 	|	aws_appmesh_mesh.main |
| cloudmap_service            | 	   	Y 		| 	    -	 	|	  object 	| 	    -	 	|	aws_service_discovery_private_dns_namespace.main |
| fargate_cpu                 | 	   	N 		| 	  "1024"	|	  string 	| 	    -	 	|	"2048" |              
| fargate_memory              | 	   	N 		| 	  "2048"	|	  string 	| 	    -	 	|	"4096" |              
| prefix 		                  | 	    N 		| 	  "EFA"	 	|	  string 	| 	    -	 	|	"AGT" |
| app_image 	                | 	    N 		| 	  "none"	|	  string 	| Default will create ECR	 	|	"nginx:1.13.9-alpine" |
| engress_cidr_blocks         |       N     |    vpc.default.cidr_block     | list(string) | egress cidr blocks allowed for app mesh services | ["1.2.3.4/0"] |
| container_insights          |       N     |   true    | bool       | enable container insights for ecs clusters |  false |
| sg_prefixs                 |       N     |       []    |  list(string) | vpc endpoint prefixs to be added to sg    | ["com.amazonaws.us-east-1.s3"] |
| min_app_count               | 	   	N 		| 	    1	 	|	  number 	| 	    -	 	|	1 |
| max_app_count               |       N     |      10   |   number  |       -   | 100 |
| log_retention_in_days       |       N     |      90   |   number  |       log retention in days   | 14 |
| ecr_kms_key_arn             |       N     |      ""   |   string  | KMS keys used to encrypt ECR images | aws_kms_key.ecr_kms.key_id |
| cloudwatch_kms_key_arn      |       N     |      ""   |   string  | KMS keys used to encrypt cloudwatch logs | aws_kms_key.cloudwatch_log_kms.arn | 
| extra_ports 	              | 	   	N 		| 	    []	 	|  list(string)	| Open extra port in task definition	 	|	["443","542"] |
| enable_cross_zone_load_balancing  |       N     |       false    |  bool | Enable cross zone load balancing for lb    | true |
| lb_access_logs_s3_bucket    |       N     |       ""    |  string | lb_access_log must be enable to provide s3 bucket name to store lb access logs    | lb-access-log-bucket |
| secrets 	              	  | 	   	N 		| 	    []	 	|  list(object) | Will add IAM permissions and secrets to task definition |	[aws_secretsmanager_secret.main.usernamer,aws_secretsmanager_secret.main.password]|
| parameters                  |       N     |       []    | list(object)  | Will add IAM permissions and parameters to task defintion as env variables | [aws_ssm_parameter.main.configs] |
| policy_arn_attachments      |     N       |       []    | list(string)   | can provide addition policies arns to be attached to ecs roles | [arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole] |
| aws_appmesh_virtual_node_arn 	  | 	   	N 		| 	  "none"	|	  string 	| virtual node or virtual gateway must be present|aws_appmesh_virtual_node.main.arn |
| virtual_gateway_arn             | 	   	N 		| 	  "none"	|	  string 	| virtual node or virtual gateway must be present| aws_appmesh_virtual_gateway.main.arn |
| envoy_proxy_image           | 	   	N 		|"840364872350.dkr.ecr.us-east-1.amazonaws.com/aws-appmesh-envoy:v1.22.2.1-prod"|string|work for all regions except: me-south-1, ap-east-1, and eu-south-1  |me-south-1 : "772975370895.dkr.ecr.me-south-1.amazonaws.com/aws-appmesh-envoy:v1.22.0.0-prod" |
| certificate                 | 	   	N 		| 	  false 	|	  bool 	| make sure to set this to true if providing certificate arn |	true |
| certificate_arn             |       N     |     "none"  |   string  |set certificate on LB| aws_acm_certificate.privateCA.arn |
| nlb_stickiness              | 	   	N 		| 	   false	|	  bool 		|enable stickiness for network load balancer|	true |
| xray			              | 	   	N 		| 	   false	|	  bool 		|add xray daemon as sidecar	 	|	true |
| tags               		  | 	   	N 		|{Terraform = "true",Module    = "ecs-fargate-appmesh"}	 |	  map(string) 	| 	    -	 	|	{name = "test"} |

## Output Variables
|   Variable  	   | 
| -------------    |
| ecs_cluster_arn  | 
| ecs_service_arn  |
| ecr_repo_url 	   |
| ecr_repo_name    |
| nlb_arn 		   |
| target_group_arn |

## Authors

* **g31s** - *Initial work* - [g31s](https://github.com/g31s)
* **tajinder1337** - [tajinder1337](https://github.com/tajinder1337)  

See also the list of [contributors](https://github.com/g31s/ecs-fargate/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License v3.0 License - see the [LICENSE.md](LICENSE.md) file for details