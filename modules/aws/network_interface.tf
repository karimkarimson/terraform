resource "aws_network_interface" "eni_vpc_name" {
  description     = "ENI for Subnet VPC"
  subnet_id       = aws_subnet.vpc_name.id
  security_groups = [aws_security_group.sg_name.id]
  attachment {
    instance     = aws_instance.instance_name.id
    device_index = 1
  }
}