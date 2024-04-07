output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "cluster_token" {
  value     = data.aws_eks_cluster_auth.auth.token
  sensitive = true
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_node_public_ips" {
  value = data.aws_instances.selected.public_ips
}

output "connection_type" {
  value = var.connection_type
}

output "connection_user" {
  value = var.connection_user
}

output "node_init_script" {
  value = var.node_init_script
}