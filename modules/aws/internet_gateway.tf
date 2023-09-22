resource "aws_internet_gateway" "igw_name" {
  vpc_id = aws_vpc.igw_name.id
  tags = {
    Name = "igw_name"
  }
}