resource "aws_vpc_peering_connection" "peering_connection_name" {
  vpc_id      = aws_vpc.vpc_name.id
  peer_vpc_id = aws_vpc.vpc_2_name.id
  auto_accept = true # if in the same Region
  tags = {
    Name = "VPC Peering Name"
  }
}