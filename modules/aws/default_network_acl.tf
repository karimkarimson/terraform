resource "aws_default_network_acl" "nacl_a" {
  default_network_acl_id = aws_vpc.vpc_name.default_network_acl_id
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
}