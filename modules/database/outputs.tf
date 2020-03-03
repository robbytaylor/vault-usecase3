output instance_ip {
  value = aws_instance.database.*.public_ip
}
