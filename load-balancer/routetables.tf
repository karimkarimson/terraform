# create route tables for public subnets
resource "aws_route_table" "wegeverzeichnis" {
  vpc_id = aws_vpc.mynet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waytogo.id
  }
}

# associate route table
resource "aws_route_table_association" "wegeverbindung" {
  count = length(var.subnet_cidr)

  subnet_id      = aws_subnet.publics[count.index].id
  route_table_id = aws_route_table.wegeverzeichnis.id
}
