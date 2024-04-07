## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.cloudwatch_observability](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_role_policy_attachment.awsXrayWriteOnlyAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudWatchAgentServerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ports_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [null_resource.local_exec](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remote_exec](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster_auth.auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_instances.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_security_group.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_ipv4"></a> [allowed\_cidr\_ipv4](#input\_allowed\_cidr\_ipv4) | The allowed CIDR by the EKS node security group | `string` | `"0.0.0.0/0"` | no |
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | The allowed ports by the EKS node security group | `list(number)` | <pre>[<br>  80,<br>  443<br>]</pre> | no |
| <a name="input_arch"></a> [arch](#input\_arch) | The underlying architecture on which the walrus server runs | `string` | `"amd64"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The cluster name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The cluster version of the EKS cluster | `string` | `"1.29"` | no |
| <a name="input_connection_type"></a> [connection\_type](#input\_connection\_type) | The connection type, only support SSH in this module | `string` | `"ssh"` | no |
| <a name="input_connection_user"></a> [connection\_user](#input\_connection\_user) | The user to use for the connection | `string` | `"ec2-user"` | no |
| <a name="input_enable_cloudwatch_observability"></a> [enable\_cloudwatch\_observability](#input\_enable\_cloudwatch\_observability) | Enable AWS CloudWatch observability for EKS cluster | `bool` | `false` | no |
| <a name="input_env_type"></a> [env\_type](#input\_env\_type) | The environment type of the Kubernetes connector | `string` | `"development"` | no |
| <a name="input_executed_repeatedly"></a> [executed\_repeatedly](#input\_executed\_repeatedly) | Allow command to be executed repeatedly | `bool` | `true` | no |
| <a name="input_k8s_connector_name"></a> [k8s\_connector\_name](#input\_k8s\_connector\_name) | Name of the Kubernetes connector | `string` | n/a | yes |
| <a name="input_node_init_script"></a> [node\_init\_script](#input\_node\_init\_script) | User-defined init script to customize the OS configuration behaviors of the EKS nodes and to pass data into the EKS nodes | `string` | `"#!/bin/bash\nyum install -y vim\necho \"OS initialized by Seal Walrus!\" > /home/ec2-user/seal\n"` | no |
| <a name="input_os"></a> [os](#input\_os) | The underlying OS on which the walrus server runs | `string` | `"linux"` | no |
| <a name="input_ssh_key_pair_content"></a> [ssh\_key\_pair\_content](#input\_ssh\_key\_pair\_content) | The content of an SSH key to use for the connection | `string` | `""` | no |
| <a name="input_ssh_key_pair_name"></a> [ssh\_key\_pair\_name](#input\_ssh\_key\_pair\_name) | The SSH key pair name to connect to the EKS node | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | <pre>{<br>  "terraform_created": "true",<br>  "walrus_managed": "true"<br>}</pre> | no |
| <a name="input_walrus_token"></a> [walrus\_token](#input\_walrus\_token) | API Token for authenticating with the Walrus server | `string` | n/a | yes |
| <a name="input_walrus_url"></a> [walrus\_url](#input\_walrus\_url) | URL of the Walrus server | `string` | `"https://localhost"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | n/a |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | n/a |
| <a name="output_cluster_token"></a> [cluster\_token](#output\_cluster\_token) | n/a |
| <a name="output_connection_type"></a> [connection\_type](#output\_connection\_type) | n/a |
| <a name="output_connection_user"></a> [connection\_user](#output\_connection\_user) | n/a |
| <a name="output_eks_node_public_ips"></a> [eks\_node\_public\_ips](#output\_eks\_node\_public\_ips) | n/a |
| <a name="output_node_init_script"></a> [node\_init\_script](#output\_node\_init\_script) | n/a |
