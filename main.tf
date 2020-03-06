module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = var.azs
  public_subnets = var.public_subnets

  tags = var.tags
}

module vault {
  source = "./modules/vault"

  instance_count   = var.instance_count
  instance_size    = var.instance_size
  public_subnets   = module.vpc.public_subnets
  vpc_id           = module.vpc.vpc_id
  ami_id           = var.consul_ami_id
  keybase_username = var.keybase_username

  security_group_ids = [module.consul_cluster.security_group_id]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name            = var.ssh_key_name

  region = var.region

  tags = merge({
    "${var.cluster_tag_key}" : var.cluster_tag_value
  }, var.tags)
}

module consul_cluster {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.7.4"


  # Add this tag to each node in the cluster
  cluster_tag_key   = var.cluster_tag_key
  cluster_tag_value = var.cluster_tag_value
  cluster_name      = "consul"

  instance_type = "t2.micro"

  ami_id                      = var.consul_ami_id
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.public_subnets
  allowed_inbound_cidr_blocks = ["${var.ssh_allowed_ip}/32"]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name            = var.ssh_key_name

  user_data = <<-EOF
    #!/bin/bash
    /opt/consul/bin/run-consul --server --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example
  EOF
}
