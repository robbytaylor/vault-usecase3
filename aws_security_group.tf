resource aws_security_group web {
  name        = var.security_group_web
  description = "Allow inbound traffic from ALB"
  vpc_id      = module.vpc.vpc_id
}

resource aws_security_group_rule http_ingress {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id

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
  name        = var.security_group_alb
  description = "Allow inbound HTTP and HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

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
