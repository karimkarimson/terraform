# Create VPCs
resource "aws_vpc" "mynet" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "TF-mynet"
  }
}