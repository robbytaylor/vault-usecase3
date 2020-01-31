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

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.7.4"

  ami_id = "ami-02d704b4b23793050"

  # Add this tag to each node in the cluster
  cluster_tag_key   = "consul-cluster"
  cluster_tag_value = "consul-cluster-example"
  cluster_name      = "consul"

  instance_type = "t2.micro"

  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.public_subnets
  allowed_inbound_cidr_blocks = ["${var.ecs_office_ip}/32"]

  user_data = <<-EOF
    #!/bin/bash
    /opt/consul/bin/run-consul --server --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example
  EOF
}
