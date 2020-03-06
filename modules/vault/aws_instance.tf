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

  user_data = base64encode(templatefile("${path.module}/files/install.sh", {
    cloudwatch_log_group = var.cloudwatch_log_group,
    keybase_username     = var.keybase_username,
    kms_key_id           = aws_kms_key.vault.id,
    region               = var.region

    install_vault_ca               = file("${path.module}/files/vault_ca.sh")
    install_vault_ssh_certificates = templatefile("${path.module}/files/vault_ssh_certificates.sh", {
      region = var.region
    })
  }))

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
