resource "aws_security_group" "sg_name" {
  name        = "sg_name"
  description = "SG of Instances in VPC"
  vpc_id      = aws_vpc.vpc_name.id
  ingress {
    description = "SSH from Everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}