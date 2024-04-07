variable "cluster_name" {
  type        = string
  description = "The cluster name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "The cluster version of the EKS cluster"
  default     = "1.29"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default = {
    "walrus_managed"    = "true"
    "terraform_created" = "true"
  }
}

variable "enable_cloudwatch_observability" {
  type        = bool
  description = "Enable AWS CloudWatch observability for EKS cluster"
  default     = false
}

variable "walrus_url" {
  type        = string
  description = "URL of the Walrus server"
  default     = "https://localhost"
}

variable "walrus_token" {
  type        = string
  description = "API Token for authenticating with the Walrus server"
}

variable "arch" {
  type        = string
  description = "The underlying architecture on which the walrus server runs"
  default     = "amd64"
}

variable "os" {
  type        = string
  description = "The underlying OS on which the walrus server runs"
  default     = "linux"
}

variable "k8s_connector_name" {
  type        = string
  description = "Name of the Kubernetes connector"
}

variable "env_type" {
  type        = string
  description = "The environment type of the Kubernetes connector"
  default     = "development"
}

variable "executed_repeatedly" {
  type        = bool
  description = "Allow command to be executed repeatedly"
  default     = true
}

variable "allowed_cidr_ipv4" {
  type        = string
  description = "The allowed CIDR by the EKS node security group"
  default     = "0.0.0.0/0"
}

variable "allowed_ports" {
  type        = list(number)
  description = "The allowed ports by the EKS node security group"
  default     = [80, 443]
}

variable "ssh_key_pair_name" {
  type        = string
  description = "The SSH key pair name to connect to the EKS node"
  default     = ""
}

variable "connection_type" {
  type        = string
  description = "The connection type, only support SSH in this module"
  default     = "ssh"
}

variable "connection_user" {
  type        = string
  description = "The user to use for the connection"
  default     = "ec2-user"
}

variable "ssh_key_pair_content" {
  type        = string
  description = "The content of an SSH key to use for the connection"
  sensitive   = true
  default     = ""
}

variable "node_init_script" {
  type        = string
  description = "User-defined init script to customize the OS configuration behaviors of the EKS nodes and to pass data into the EKS nodes"
  default     = <<-EOT
              #!/bin/bash
              yum install -y vim
              echo "OS initialized by Seal Walrus!" > /home/ec2-user/seal
              EOT
}