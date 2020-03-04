resource aws_autoscaling_group vault {
  launch_template {
    id      = aws_launch_template.vault.id
    version = "$Latest"
  }

  min_size         = var.instance_count
  max_size         = var.instance_count
  desired_capacity = var.instance_count

  vpc_zone_identifier = var.public_subnets
}

resource aws_launch_template vault {
  image_id      = var.ami_id
  instance_type = var.instance_size
  key_name      = var.ssh_key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y unzip wget

    /opt/consul/bin/run-consul --client --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example

    cd /tmp
    wget https://releases.hashicorp.com/vault/1.3.2/vault_1.3.2_linux_amd64.zip
    unzip vault_1.3.2_linux_amd64.zip

    mv /tmp/vault /usr/local/bin/

    mkdir /etc/vault/

    echo '
      storage "consul" {
        address = "127.0.0.1:8500"
        path    = "vault"
      }

      listener "tcp" {
        address     = "127.0.0.1:8200"
        tls_disable = 1
      }

      seal "awskms" {
        region = "${var.region}"
        kms_key_id = "${aws_kms_key.vault.id}"
      }
    ' > /etc/vault/config.hcl

    echo '{"service":
      {"name": "vault",
      "tags": ["vault"],
      "port": 8200,
      "check": {
        "id": "vault_check",
        "name": "Check vault health",
        "service_id": "vault",
        "http": "http://localhost:8200/",
        "method": "GET",
        "interval": "10s",
        "timeout": "1s"
      }}
      }
    }' > /opt/consul/config/vault.json

    consul reload
    /usr/local/bin/vault server -config /etc/vault/config.hcl
EOF
)

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    security_groups = concat([aws_security_group.vault.id], var.security_group_ids)
  }

  tags = var.tags
}

resource aws_iam_instance_profile instance_profile {
  role = aws_iam_role.vault.name
}

resource aws_kms_key vault {}