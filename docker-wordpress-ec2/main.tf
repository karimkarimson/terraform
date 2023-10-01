terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "> 5.1.0"

  name = "docker-ec2"
  azs  = data.aws_availability_zones.available.names

  tags = {
    Name = "docker-ec2"
  }

  cidr           = "10.0.0.0/24"
  public_subnets = ["10.0.0.0/24"]

  create_igw = true
}

# define security_group
resource "aws_security_group" "docker_sg" {
  depends_on  = [module.vpc]
  name        = "docker_sg"
  description = "http and ssh from everywhere"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "SSH from Everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
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

# create EC2 instance
resource "aws_instance" "docker_ec2" {
  depends_on = [aws_security_group.docker_sg]

  ami                         = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = "ssh-september"
  tags = {
    Name = "Docker EC2 Instance"
  }
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  connection {
    type        = "ssh"
    host        = aws_instance.docker_ec2.public_ip
    user        = "ubuntu"
    private_key = file("C:\\Users\\karim\\.ssh\\aws-september")
  }
  provisioner "file" {
    source      = ".env.docker.dev"
    destination = "/home/ubuntu/.env.docker.dev"
  }
  provisioner "file" {
    source      = ".htpass"
    destination = "/home/ubuntu/.htpass"
  }

  provisioner "remote-exec" {
    script = "script.sh"
  }
}
