resource aws_security_group web {
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.vpc_id
}

resource aws_security_group_rule http_ingress {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id

  security_group_id = aws_security_group.web.id
}

resource aws_security_group_rule ssh_ingress {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = var.allowed_ssh_cidr_blocks

  security_group_id = aws_security_group.web.id
}

resource aws_security_group_rule web_egress {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource aws_security_group alb {
  description = "Allow inbound HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group_rule alb {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id

  security_group_id = aws_security_group.alb.id
}
