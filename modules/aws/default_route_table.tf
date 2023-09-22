resource "aws_default_route_table" "rt_name" {
  default_route_table_id = aws_vpc.vpc_name.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_name.id
  }
  route {
    cidr_block = "192.168.0.0/24"
    gateway_id = aws_vpc_peering_connection.peering_connection_name.id
  }
}