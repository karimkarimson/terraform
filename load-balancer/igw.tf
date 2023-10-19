# create Internet Gateway for Jumphosts
resource "aws_internet_gateway" "waytogo" {
  vpc_id = aws_vpc.mynet.id
  tags = {
    Name = "Internet-Gateway-TF-mynet"
  }
}