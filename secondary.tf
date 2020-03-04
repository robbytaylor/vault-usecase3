module secondary_vpc {
  source   = "terraform-aws-modules/vpc/aws"

  name = var.secondary_vpc_name
  cidr = var.secondary_vpc_cidr

  azs            = var.secondary_azs
  public_subnets = var.secondary_public_subnets

  tags = var.tags

  providers = {
    aws = aws.secondary
  }
}

module secondary_vault {
  source   = "./modules/vault"

  instance_count = var.instance_count
  instance_size  = var.instance_size
  public_subnets = module.secondary_vpc.public_subnets
  vpc_id         = module.secondary_vpc.vpc_id
  ami_id         = var.consul_ami_id

  security_group_ids = [module.secondary_consul_cluster.security_group_id]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name            = var.ssh_key_name

  region = var.secondary_region

  tags = merge({
    "${var.cluster_tag_key}" : var.cluster_tag_value
  }, var.tags)

  providers = {
    aws = aws.secondary
  }
}

module secondary_consul_cluster {
  source   = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.7.4"

  # Add this tag to each node in the cluster
  cluster_tag_key   = var.cluster_tag_key
  cluster_tag_value = var.cluster_tag_value
  cluster_name      = "consul"

  instance_type = "t2.micro"

  ami_id                      = var.consul_ami_id
  vpc_id                      = module.secondary_vpc.vpc_id
  subnet_ids                  = module.secondary_vpc.public_subnets
  allowed_inbound_cidr_blocks = ["${var.ssh_allowed_ip}/32"]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name            = var.ssh_key_name

  user_data = <<-EOF
    #!/bin/bash
    /opt/consul/bin/run-consul --server --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example
  EOF

  providers = {
    aws = aws.secondary
  }
}
