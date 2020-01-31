variable public_subnets {
  type = list(string)
}

variable vpc_id {
  type = string
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

variable user_data {
  type    = string
  default = <<-EOF
    #!/bin/bash
    apt update
    apt upgrade
    apt install -y apache2
EOF
}
