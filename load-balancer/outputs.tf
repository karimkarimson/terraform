output "instances_public_ips" {
  value = aws_instance.servers.*.public_ip
}
output "load_balancer_ip" {
  value = aws_lb.verteiler.dns_name
}