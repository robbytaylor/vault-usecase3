resource aws_instance web {
  count = var.instance_count

  ami           = "ami-02d704b4b23793050"
  instance_type = var.instance_size
  subnet_id     = var.public_subnets[0]
  key_name      = var.ssh_key_name

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

  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = concat([aws_security_group.web.id], var.security_group_ids)
  tags                   = var.tags
}

resource aws_iam_instance_profile instance_profile {
  role = var.iam_role_name
}
