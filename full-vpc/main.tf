# Create VPCs
resource "aws_vpc" "mynet" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "TF-mynet"
  }
}

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
resource "aws_subnet" "privates" {
  count = length(var.private_subnet_cidr)

  vpc_id = aws_vpc.mynet.id

  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false
  tags = {
    Name = "TF-Private-Subnet-${count.index}"
  }
}

# create Internet Gateway for Jumphosts
resource "aws_internet_gateway" "waytogo" {
  vpc_id = aws_vpc.mynet.id
  tags = {
    Name = "Internet-Gateway-TF-mynet"
  }
}

# Get EIPs for NAT-Gateways
resource "aws_eip" "natips" {
  count  = length(var.subnet_cidr)
  domain = "vpc"
}
# Create NAT-Gateways
resource "aws_nat_gateway" "verbinder" {
  count = length(var.subnet_cidr)

  allocation_id = aws_eip.natips[count.index].id
  subnet_id     = aws_subnet.publics[count.index].id

  tags = {
    Name = "TF-NAT-Gateway-${count.index}"
  }

  depends_on = [aws_internet_gateway.waytogo]
}

# create route tables for public subnets
resource "aws_route_table" "wegeverzeichnis" {
  vpc_id = aws_vpc.mynet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waytogo.id
  }
}

resource "aws_route_table_association" "wegeverbindung" {
  count = length(var.subnet_cidr)

  subnet_id      = aws_subnet.publics[count.index].id
  route_table_id = aws_route_table.wegeverzeichnis.id
}

# create route tables for private subnets
resource "aws_route_table" "privatwegeverzeichnis" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.mynet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.verbinder[count.index].id
  }
}

resource "aws_route_table_association" "privatwegeverbindung" {
  count = length(var.subnet_cidr)

  subnet_id      = aws_subnet.privates[count.index].id
  route_table_id = aws_route_table.privatwegeverzeichnis[count.index].id
}

resource "aws_security_group" "server_sgs" {
  name        = "tf_server_sgs"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.mynet.id

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

# Load Shell-Script for Instances
data "template_file" "initscript" {
  template = file("./script.sh")
}

# create Jumphosts in all public subnets
resource "aws_instance" "jumphosts" {
  count         = length(var.subnet_cidr)
  ami           = "ami-06dd92ecc74fdfb36"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.publics[count.index].id

  associate_public_ip_address = true
  key_name                    = "ssh-october"

  vpc_security_group_ids = [aws_security_group.server_sgs.id]

  tags = {
    Name = "TF-Server-${count.index}"
  }
}

# create Instances in all private subnets
resource "aws_instance" "servers" {
  count         = length(var.private_subnet_cidr)
  ami           = "ami-06dd92ecc74fdfb36"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.privates[count.index].id

  associate_public_ip_address = false
  key_name                    = "ssh-jumphost"

  vpc_security_group_ids = [aws_security_group.server_sgs.id]

  tags = {
    Name = "TF-Private-Server-${count.index}"
  }
}