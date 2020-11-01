# Terraform AWS ECS Fargate Module

This module create fargate cluster in ECS. Module is desinged to quicly implement fargate cluster for appmesh microservices or virtual gateway. Following are the features

## Features
- Appmesh 
- Cloudmap service
- Virtual Gateway envoy proxy with load balancer
- Sidecars supported:
	- envoy proxy
	- aws xray
- Secret Manager
- Elastic container registory (ECR)
- Auto Scalling
- Cloudwatch Dashboard
- SSL cert on LB

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
|   Variable  	              |    Required		| 	 Default	| 	   Type	 	|	   Info	 	|    Example    |
| -------------               | ------------- 	| ------------- | ------------- | ------------- | ------------- |
| vpc 		              	  | 	    Y 		| 	    -	 	|	  object 	| 	    -	 	|	module.vpc from terraform vpc module will be one example |
| region 	              	  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"us-east-1" |
| env 		              	  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"dev" |
| app_name 	                  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"test" |
| app_port 	              	  | 	    Y 		| 	    -	 	|	  string 	| 	    -	 	|	"80" |
| appmesh 	              	  | 	    Y 		| 	    -	 	|	  object 	| 	    -	 	|	aws_appmesh_mesh.main |
| cloudmap_service            | 	   	Y 		| 	    -	 	|	  object 	| 	    -	 	|	aws_service_discovery_private_dns_namespace.main |
| fargate_cpu                 | 	   	N 		| 	  "1024"	|	  string 	| 	    -	 	|	"2048" |              
| fargate_memory              | 	   	N 		| 	  "2048"	|	  string 	| 	    -	 	|	"4096" |              
| prefix 		              | 	    N 		| 	  "EFA"	 	|	  string 	| 	    -	 	|	"AGT" |
| app_image 	              | 	    N 		| 	  "none"	|	  string 	| Default will create ECR	 	|	"nginx:1.13.9-alpine" |
| min_app_count               | 	   	N 		| 	    1	 	|	  number 	| 	    -	 	|	"1" |
| extra_ports 	              | 	   	N 		| 	    []	 	|  list(string)	| Open extra port in task definition	 	|	["443","542"] |
| secrets 	              	  | 	   	N 		| 	    []	 	|  list(string) | Will add IAM permissions and secrets to task definition |	["db_name","db_pass"]|
| aws_appmesh_virtual_node 	  | 	   	N 		| 	  "none"	|	  string 	| virtual node or virtual gateway must be present|aws_appmesh_virtual_node.main.name |
| virtual_gateway             | 	   	N 		| 	  "none"	|	  string 	| virtual node or virtual gateway must be present|"test_virtual_gateway" |
| envoy_proxy_image           | 	   	N 		|"840364872350.dkr.ecr.us-east-1.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod"|string|work for all regions expect: me-south-1, ap-east-1, and eu-south-1  |me-south-1 : "772975370895.dkr.ecr.me-south-1.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod" |
| certificate_arn             | 	   	N 		| 	  "none"	|	  string 	|set certificate on LB|	aws_acm_certificate.privateCA.arn |
| nlb_stickiness              | 	   	N 		| 	   false	|	  bool 		|enable stickiness for network load balacner|	true |
| xray			              | 	   	N 		| 	   false	|	  bool 		|add xray demon as sidecar	 	|	true |
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

See also the list of [contributors](https://github.com/g31s/ecs-fargate/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License v3.0 License - see the [LICENSE.md](LICENSE.md) file for details