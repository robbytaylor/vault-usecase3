resource aws_security_group vault {
  description = "vault security group"
  vpc_id      = var.vpc_id
}

resource aws_security_group_rule http_ingress {
  type        = "ingress"
  from_port   = 8200
  to_port     = 8200
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks

  security_group_id = aws_security_group.vault.id
}

resource aws_security_group_rule ssh_ingress {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks

  security_group_id = aws_security_group.vault.id
}

resource aws_security_group_rule vault_egress {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.vault.id
}
