output web_alb_address {
  value = module.web.alb_address
}

output web_instance_ip {
  value = module.web.instance_ip
}

output database_instance_ip {
  value = module.database.instance_ip
}
