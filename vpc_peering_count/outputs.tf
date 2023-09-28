output "vpc_arns" {
  value = module.vpc.*.vpc_arn
}
output "vpc-ids" {
  value = module.vpc.*.vpc_id
}
output "vpc_cidr_blocks" {
  value = module.vpc.*.vpc_cidr_block
}
output "subnet_ids" {
  value = module.vpc.*.public_subnets
}
output "security_group_ids" {
  value = module.sg.*.security_group_id
}
output "igw_ids" {
  value = module.vpc.*.igw_id
}
output "default_nacls" {
  value = module.vpc.*.default_network_acl_id
}
output "instance_ids" {
  value = module.instances.*.id
}
output "instance_public_ips" {
  value = module.instances.*.public_ip
}