resource aws_instance database {
  count = var.instance_count

  ami           = var.ami_id
  instance_type = var.instance_size
  subnet_id     = var.public_subnets[count.index % 3]
  key_name      = var.ssh_key_name

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

  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = concat([aws_security_group.database.id], var.security_group_ids)
  tags                   = var.tags
}

resource aws_iam_instance_profile instance_profile {
  role = var.iam_role_name
}
