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
resource "aws_subnet" "a" {
  vpc_id     = aws_vpc.a.id
  cidr_block = "10.0.0.0/24"
}
resource "aws_subnet" "b" {
  vpc_id     = aws_vpc.b.id
  cidr_block = "192.168.0.0/24"
}

resource "aws_vpc_peering_connection" "aNACHb" {
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true
  tags = {
    Name = "VPC Peering aNACHb"
  }
}

resource "aws_instance" "vpca" {
  ami                         = "ami-0b9094fa2b07038b8"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.a.id
  associate_public_ip_address = true
  key_name                    = "ssh-september"

  tags = {
    Name = "vpc_a_instance"
  }
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_icmp.id]
}
resource "aws_instance" "vpcb" {
  ami                         = "ami-0b9094fa2b07038b8"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.b.id
  associate_public_ip_address = true
  key_name                    = "ssh-september"

  tags = {
    Name = "vpc_b_instance"
  }
}

resource "aws_security_group" "allow_ssh_http_icmp" {
  name        = "allow_ssh_http_icmp"
  description = "Allow SSH from everywhere HTTP and ICMP from VPC B"
  vpc_id      = aws_vpc.a.id

  ingress {
    description = "SSH from Everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC B"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.b.cidr_block]
  }
  ingress {
    description = "ICMP from VPC B"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "eni_vpc_a" {
  description     = "ENI for Subnet VPC A"
  subnet_id       = aws_subnet.a.id
  security_groups = [aws_security_group.allow_ssh_http_icmp.id]
  attachment {
    instance     = aws_instance.vpca.id
    device_index = 1
  }
}

resource "aws_network_interface" "eni_vpc_b" {
  description = "ENI for Subnet VPC B"
  subnet_id   = aws_subnet.b.id
  attachment {
    instance     = aws_instance.vpcb.id
    device_index = 1
  }
}


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

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = aws_vpc_peering_connection.aNACHb.id
  }
}

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