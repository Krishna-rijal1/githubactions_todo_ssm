output "instance_ip" {
  value = aws_instance.ansible_conf.public_ip
}