output "vpc_a_id" {
  description = "ID of the VPC A"
  value       = aws_vpc.a.id
}
output "vpc_b_id" {
  description = "ID of the VPC B"
  value       = aws_vpc.b.id
}
output "vpc_a_subnet_id" {
  description = "ID of the Subnet in VPC A"
  value       = aws_subnet.a.id
}
output "vpc_b_subnet_id" {
  description = "ID of the Subnet in VPC B"
  value       = aws_subnet.b.id
}
output "vpc_peering_id" {
  description = "ID of the VPC Peering"
  value       = aws_vpc_peering_connection.aNACHb.id
}
output "security_group_id" {
  description = "ID of the SG"
  value       = aws_security_group.allow_ssh_http_icmp.id
}
output "eni_id" {
  description = "ID of the ENI for instance in VPC A"
  value       = aws_network_interface.eni_vpc_a.id
}
output "vpc_a_instance_ip" {
  value = aws_instance.vpca.public_ip
}
output "vpc_b_instance_ip" {
  value = aws_instance.vpcb.public_ip
}