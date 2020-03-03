module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = var.azs
  public_subnets = var.public_subnets

  tags = var.tags
}

module web {
  source = "./modules/instances"

  instance_count = var.instance_count
  instance_size  = var.instance_size
  public_subnets = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name = var.ssh_key_name

  iam_role_name      = module.consul_cluster.iam_role_id
  security_group_ids = [module.consul_cluster.security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2

    /opt/consul/bin/run-consul --client --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example

    echo '{"service":
      {"name": "web",
      "tags": ["web"],
      "port": 80,
      "check": {
        "id": "webserver_check",
        "name": "Check webserver health",
        "service_id": "webserver",
        "http": "http://localhost/",
        "method": "GET",
        "interval": "10s",
        "timeout": "1s"
      }}
    }' > /opt/consul/config/web.json

    consul reload
EOF

  tags = merge({
    "consul-cluster" : "consul-cluster-example"
  }, var.tags)
}

module database {
  source = "./modules/instances"

  instance_count = var.instance_count
  instance_size  = var.instance_size
  public_subnets = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id

  iam_role_name      = module.consul_cluster.iam_role_id
  security_group_ids = [module.consul_cluster.security_group_id]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name = var.ssh_key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update

    echo mysql-server mysql-server/root_password select password | debconf-set-selections
    echo mysql-server mysql-server/root_password_again select password | debconf-set-selections

    apt-get install -y mysql-server

    /opt/consul/bin/run-consul --client --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example

    echo '{"service":
      {"name": "database",
      "tags": ["database"],
      "port": 3306,
      "check": {
        "id": "database_check",
        "name": "Check MySQL health",
        "service_id": "mysql",
        "tcp": "localhost:3306",
        "interval": "10s",
        "timeout": "1s"
      }
      }
    }' > /opt/consul/config/web.json

    consul reload
EOF

  tags = merge({
    "consul-cluster" : "consul-cluster-example"
  }, var.tags)
}

module consul_cluster {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.7.4"

  ami_id = "ami-02d704b4b23793050"

  # Add this tag to each node in the cluster
  cluster_tag_key   = "consul-cluster"
  cluster_tag_value = "consul-cluster-example"
  cluster_name      = "consul"

  instance_type = "t2.micro"

  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.public_subnets
  allowed_inbound_cidr_blocks = ["${var.ssh_allowed_ip}/32"]

  allowed_ssh_cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  ssh_key_name = var.ssh_key_name

  user_data = <<-EOF
    #!/bin/bash
    /opt/consul/bin/run-consul --server --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example
  EOF
}
