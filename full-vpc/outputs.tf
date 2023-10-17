output "jumphost_public_ips" {
  value = aws_instance.jumphosts.*.public_ip
}
output "servers_private_ips" {
  value = aws_instance.servers.*.private_ip
}