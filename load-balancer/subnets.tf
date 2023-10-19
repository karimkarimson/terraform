# create Subnets 
resource "aws_subnet" "publics" {
  count = length(var.subnet_cidr)

  vpc_id = aws_vpc.mynet.id

  cidr_block        = var.subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true
  tags = {
    Name = "TF-Public-Subnet-${count.index}"
  }
}