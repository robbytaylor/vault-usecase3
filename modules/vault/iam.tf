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

data aws_iam_policy_document vault-kms-unseal {
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
}

resource aws_iam_role vault {
  name               = "vault-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource aws_iam_role_policy vault-kms-unseal {
  name   = "Vault-KMS-Unseal"
  role   = aws_iam_role.vault.id
  policy = data.aws_iam_policy_document.vault-kms-unseal.json
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
