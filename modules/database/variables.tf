variable ami_id {
  type = string
}

variable iam_role_name {
  type    = string
}

variable public_subnets {
  type = list(string)
}

variable vpc_id {
  type = string
}

variable web_security_group_id {
  type = string
}

variable allowed_ssh_cidr_blocks {
  type    = list(string)
  default = []
}

variable instance_count {
  type    = number
  default = 3
}

variable instance_size {
  type    = string
  default = "t2.micro"
}

variable security_group_ids {
  type    = list(string)
  default = []
}

variable ssh_key_name {
  type    = string
  default = ""
}

variable tags {
  type    = map
  default = {}
}
