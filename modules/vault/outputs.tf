output instance_ip {
  value = aws_instance.vault.*.public_ip
}
