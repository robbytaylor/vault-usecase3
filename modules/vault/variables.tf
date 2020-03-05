locals {
  account_id = data.aws_caller_identity.current.account_id
}

variable ami_id {
  type = string
}

variable public_subnets {
  type = list(string)
}

variable region {
  type = string
}

variable vpc_id {
  type = string
}

variable allowed_ssh_cidr_blocks {
  type    = list(string)
  default = []
}

variable cloudwatch_log_group {
  type    = string
  default = "vault"
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
