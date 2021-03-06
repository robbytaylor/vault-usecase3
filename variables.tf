variable keybase_username {
  type = string
}

variable ssh_allowed_ip {
  type = string
}

variable ssh_key_name {
  type = string
}

variable azs {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable cluster_tag_key {
  type    = string
  default = "consul-cluster"
}

variable cluster_tag_value {
  type    = string
  default = "consul-cluster-example"
}

variable consul_ami_id {
  type    = string
  default = "ami-02d704b4b23793050"
}

variable instance_count {
  type    = number
  default = 3
}

variable instance_size {
  type    = string
  default = "t2.micro"
}

variable tags {
  type    = map
  default = {}
}

variable public_subnets {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable region {
  type    = string
  default = "eu-west-1"
}

variable vpc_cidr {
  type    = string
  default = "10.0.0.0/16"
}

variable vpc_name {
  type    = string
  default = "VaultUseCaseVpc"
}

variable secondary_azs {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable secondary_region {
  type    = string
  default = "eu-west-2"
}

variable secondary_vpc_cidr {
  type    = string
  default = "10.1.0.0/16"
}

variable secondary_public_subnets {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
}

variable secondary_vpc_name {
  type    = string
  default = "VaultUseCaseVpc"
}
