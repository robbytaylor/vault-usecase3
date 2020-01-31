variable azs {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable ecs_office_ip {
  type    = string
  default = "212.250.145.34"
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

variable user_data {
  type    = string
  default = <<-EOF
    #!/bin/bash
    apt update
    apt upgrade
    apt install -y apache2
EOF
}

variable vpc_cidr {
  type    = string
  default = "10.0.0.0/16"
}

variable vpc_name {
  type    = string
  default = "TerraformUseCaseVpc"
}
