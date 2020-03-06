data aws_iam_policy_document assume-role {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document vault {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }

  statement {
    sid       = "PutRecoveryShare"
    effect    = "Allow"
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/VaultRecoveryKey",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/VaultSSHPublicKey"
    ]

    actions = [
      "ssm:PutParameter"
    ]
  }
}

resource aws_iam_role vault {
  name               = "vault-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource aws_iam_role_policy vault {
  name   = "Vault"
  role   = aws_iam_role.vault.id
  policy = data.aws_iam_policy_document.vault.json
}

resource aws_iam_role_policy auto_discover_cluster {
  name   = "auto-discover-cluster"
  role   = aws_iam_role.vault.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data aws_iam_policy_document auto_discover_cluster {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

resource aws_iam_role_policy cloudwatch_logs {
  name   = "write-to-cloudwatch-logs"
  role   = aws_iam_role.vault.id
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

data aws_iam_policy_document cloudwatch_logs {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${local.account_id}:log-group:${var.cloudwatch_log_group}",
      "arn:aws:logs:${var.region}:${local.account_id}:log-group:${var.cloudwatch_log_group}:*:*"
    ]
  }
}
