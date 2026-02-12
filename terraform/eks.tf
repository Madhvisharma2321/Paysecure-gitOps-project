module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "paysecure-eks"
  cluster_version = "1.29"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  tags = {
    Project = "PaySecure"
  }
}