terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

# Create VPCs
resource "aws_vpc" "a" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-a"
  }
}
resource "aws_vpc" "b" {
  cidr_block       = "192.168.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-b"
  }
}

# create Subnets in both VPCs
resource "aws_subnet" "a" {
  vpc_id     = aws_vpc.a.id
  cidr_block = "10.0.0.0/24"
}
resource "aws_subnet" "b" {
  vpc_id     = aws_vpc.b.id
  cidr_block = "192.168.0.0/24"
}

# create NACLs
resource "aws_default_network_acl" "nacl_a" {
  default_network_acl_id = aws_vpc.a.default_network_acl_id
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "icmp"
    from_port  = 0
    to_port    = 0
    icmp_code = -1
    icmp_type = -1
    cidr_block = aws_vpc.b.cidr_block
  }
  ingress {
    rule_no    = 400
    action     = "allow"
    protocol   = "tcp"
    cidr_block = aws_vpc.b.cidr_block
    from_port  = 80
    to_port    = 80
  }
  ingress {
    rule_no    = 500
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 200
    action     = "allow"
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = "icmp"
    from_port  = 0
    to_port    = 0
    icmp_code = -1
    icmp_type = -1
  }
}
resource "aws_default_network_acl" "nacl_b" {
  default_network_acl_id = aws_vpc.b.default_network_acl_id
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "icmp"
    from_port  = 0
    to_port    = 0
    cidr_block = aws_vpc.a.cidr_block
    icmp_code = -1
    icmp_type = -1
  }
  ingress {
    rule_no    = 400
    action     = "allow"
    protocol   = "tcp"
    cidr_block = aws_vpc.a.cidr_block
    from_port  = 80
    to_port    = 80
  }
  ingress {
    rule_no    = 500
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 200
    action     = "allow"
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = "icmp"
    from_port  = 0
    to_port    = 0
    icmp_code = -1
    icmp_type = -1
  }
}

# define security_groups per vpc
resource "aws_security_group" "instance_a_sg" {
  name        = "instance_a_sg"
  description = "SG of Instances in VPC A"
  vpc_id      = aws_vpc.a.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "instance_b_sg" {
  name        = "instance_b_sg"
  description = "SG of Instances in VPC B"
  vpc_id      = aws_vpc.b.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# define rules for security_groups
resource "aws_security_group_rule" "allow_ssh_from_everywhere_a" {
  security_group_id = aws_security_group.instance_a_sg.id
  type              = "ingress"
  description       = "SSH from Everywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_http_btw_ab_a" {
  security_group_id = aws_security_group.instance_a_sg.id
  type              = "ingress"
  description       = "HTTP between VPC A and B"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.b.cidr_block]
}
resource "aws_security_group_rule" "allow_icmp_btw_ab_a" {
  security_group_id = aws_security_group.instance_a_sg.id
  type              = "ingress"
  description       = "ICMP between VPC A and B"
  from_port         = 8
  to_port           = 8
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.b.cidr_block]
}
resource "aws_security_group_rule" "allow_icmp_btw_ab_a" {
  security_group_id = aws_security_group.instance_a_sg.id
  type              = "ingress"
  description       = "ICMP between VPC A and B"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.b.cidr_block]
}
resource "aws_security_group_rule" "allow_ssh_from_everywhere_b" {
  security_group_id = aws_security_group.instance_b_sg.id
  type              = "ingress"
  description       = "SSH from Everywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_http_btw_ab_b" {
  security_group_id = aws_security_group.instance_b_sg.id
  type              = "ingress"
  description       = "HTTP between VPC A and B"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.a.cidr_block]
}
resource "aws_security_group_rule" "allow_icmp_btw_ab_b" {
  security_group_id = aws_security_group.instance_b_sg.id
  type              = "ingress"
  description       = "ICMP between VPC A and B"
  from_port         = 8
  to_port           = 8
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.a.cidr_block]
}
resource "aws_security_group_rule" "allow_icmp_btw_ab_b" {
  security_group_id = aws_security_group.instance_b_sg.id
  type              = "ingress"
  description       = "ICMP between VPC A and B"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.a.cidr_block]
}


# create VPC Peering Connection
resource "aws_vpc_peering_connection" "aNACHb" {
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true
  tags = {
    Name = "VPC Peering aNACHb"
  }
}

# create Instances in both VPCs
resource "aws_instance" "vpca" {
  ami                         = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.a.id
  associate_public_ip_address = true
  key_name                    = "ssh-september"
  tags = {
    Name = "vpc_a_instance"
  }
  vpc_security_group_ids = [aws_security_group.instance_a_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
  EOF
}
resource "aws_instance" "vpcb" {
  ami                         = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.b.id
  associate_public_ip_address = true
  key_name                    = "ssh-september"
  tags = {
    Name = "vpc_b_instance"
  }
  vpc_security_group_ids = [aws_security_group.instance_b_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
  EOF
}

# create ENIs for both VPCs
resource "aws_network_interface" "eni_vpc_a" {
  description     = "ENI for Subnet VPC A"
  subnet_id       = aws_subnet.a.id
  security_groups = [aws_security_group.instance_a_sg.id]
  attachment {
    instance     = aws_instance.vpca.id
    device_index = 1
  }
}
resource "aws_network_interface" "eni_vpc_b" {
  description     = "ENI for Subnet VPC B"
  subnet_id       = aws_subnet.b.id
  security_groups = [aws_security_group.instance_b_sg.id]
  attachment {
    instance     = aws_instance.vpcb.id
    device_index = 1
  }
}

# edit default route tables
resource "aws_default_route_table" "a" {
  default_route_table_id = aws_vpc.a.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }
  route {
    cidr_block = "192.168.0.0/24"
    gateway_id = aws_vpc_peering_connection.aNACHb.id
  }
}
resource "aws_default_route_table" "b" {
  default_route_table_id = aws_vpc.b.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = aws_vpc_peering_connection.aNACHb.id
  }
}

# create Internet Gateways
resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.a.id
  tags = {
    Name = "igw_a"
  }
}
resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.b.id
  tags = {
    Name = "igw_b"
  }
}
