resource "aws_subnet" "subnet_name" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = "0.0.0.0/0"
}