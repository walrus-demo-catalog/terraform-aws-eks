data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = join("-", [var.cluster_name, "vpc"])

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.public_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.small", "t3.small"]

    use_custom_launch_template = false
    remote_access = {
      ec2_ssh_key = var.ssh_key_pair_name
    }
  }

  eks_managed_node_groups = {
    one = {
      name = "eks-node-group-1"

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }

    two = {
      name = "eks-node-group-2"

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = var.tags
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

resource "aws_iam_role_policy_attachment" "cloudWatchAgentServerPolicy" {
  count = var.enable_cloudwatch_observability == true ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = module.eks.cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "awsXrayWriteOnlyAccess" {
  count = var.enable_cloudwatch_observability == true ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = module.eks.cluster_iam_role_name
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.enable_cloudwatch_observability == true ? 1 : 0

  cluster_name = var.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.cloudWatchAgentServerPolicy,
    aws_iam_role_policy_attachment.awsXrayWriteOnlyAccess,
  ]

  tags = {
    "eks_addon"         = "amazon-cloudwatch-observability"
    "walrus_managed"    = "true"
    "terraform_created" = "true"
  }
}

resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/commands.tpl", {
      WALRUS_URL                         = var.walrus_url
      WALRUS_TOKEN                       = var.walrus_token
      ARCN                               = var.arch
      OS                                 = var.os
      K8S_CONNECTOR_NAME                 = var.k8s_connector_name
      ENV_TYPE                           = var.env_type
      CLUSTER_ARN                        = module.eks.cluster_arn
      CLUSTER_ENDPOINT                   = module.eks.cluster_endpoint
      CLUSTER_CERTIFICATE_AUTHORITY_DATA = module.eks.cluster_certificate_authority_data
      CLUSTER_TOKEN                      = data.aws_eks_cluster_auth.auth.token
    })
  }

  depends_on = [
    module.eks
  ]

  triggers = {
    always_run = var.executed_repeatedly == true ? timestamp() : null
  }
}

locals {
  secgroup_name_prefix = "eks-cluster-sg-${var.cluster_name}"
}

data "aws_security_group" "selected" {
  filter {
    name   = "group-name"
    values = ["${local.secgroup_name_prefix}*"]
  }

  depends_on = [
    module.eks
  ]
}

resource "aws_vpc_security_group_ingress_rule" "allow_ports_ipv4" {
  count             = length(var.allowed_ports)
  security_group_id = data.aws_security_group.selected.id
  cidr_ipv4         = var.allowed_cidr_ipv4
  ip_protocol       = "tcp"
  from_port         = var.allowed_ports[count.index]
  to_port           = var.allowed_ports[count.index]
}

data "aws_instances" "selected" {
  instance_tags = {
    "aws:eks:cluster-name" = var.cluster_name
  }

  instance_state_names = ["running"]
}

resource "null_resource" "remote_exec" {
  count = length(data.aws_instances.selected.public_ips)

  connection {
    type        = var.connection_type
    host        = data.aws_instances.selected.public_ips[count.index]
    user        = var.connection_user
    private_key = var.ssh_key_pair_content != null ? var.ssh_key_pair_content : null
    timeout     = "30s"
  }

  provisioner "remote-exec" {
    inline = [var.node_init_script]
  }

  triggers = {
    always_run = var.executed_repeatedly == true ? "${timestamp()}" : null
  }
}