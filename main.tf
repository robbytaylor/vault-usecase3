module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = var.azs
  public_subnets = var.public_subnets

  tags = var.tags
}

module web {
  source = "./modules/web"

  instance_count = var.instance_count
  instance_size  = var.instance_size
  public_subnets = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id

  tags = var.tags
}
