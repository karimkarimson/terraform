resource "aws_vpc" "vpc_name" {
  cidr_block       = "0.0.0.0/0"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-name"
  }
}