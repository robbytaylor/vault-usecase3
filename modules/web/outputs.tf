output alb_address {
  value = aws_lb.web.dns_name
}

output instance_ip {
  value = aws_instance.web.*.public_ip
}

output security_group_id {
  value = aws_security_group.web.id
}
