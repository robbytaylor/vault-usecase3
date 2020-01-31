data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource aws_instance web {
  count = var.instance_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_size
  subnet_id     = module.vpc.public_subnets[0]
  user_data     = var.user_data

  security_groups = [aws_security_group.web.id]

  tags = var.tags
}
