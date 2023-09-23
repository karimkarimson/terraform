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

# Create VPCs & Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "> 5.1.0"

  name  = "vpc"
  azs   = data.aws_availability_zones.available.names
  count = length(var.vpc_cidr_blocks)

  tags = {
    Name = "vpc-${count.index + 1}"
  }

  cidr = var.vpc_cidr_blocks[count.index]
  # one public SN per VPC
  public_subnets = [var.vpc_cidr_blocks[count.index]]

  # NAT 
  # NAT needs private route Table, error in line 1088 of terraform-aws-vpc/main.tf
  # enable_nat_gateway = true

  # Internet Gateway
  create_igw = true

  # Defaults
  manage_default_network_acl    = true
  manage_default_security_group = true

  # define NACLs
  default_network_acl_name = "SSH from everywhere, HTTP and PING between VPC 1 and 2"
  default_network_acl_ingress = [
    {
      "action"     = "allow",
      "from_port"  = 22,
      "to_port"    = 22,
      "protocol"   = "tcp",
      "cidr_block" = "0.0.0.0/0",
      "rule_no"    = 100
    },
    {
      "action"     = "allow",
      "from_port"  = 0,
      "to_port"    = 0,
      "protocol"   = "icmp",
      "icmp_code"  = -1,
      "icmp_type"  = -1,
      "cidr_block" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0]),
      "rule_no"    = 200
    },
    {
      "action"     = "allow",
      "from_port"  = 80,
      "to_port"    = 80,
      "protocol"   = "tcp",
      "cidr_block" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0]),
      "rule_no"    = 300
    },
    {
      "action"     = "allow",
      "from_port"  = 1024,
      "to_port"    = 65535,
      "protocol"   = "tcp",
      "cidr_block" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0]),
      "rule_no"    = 400
    }
  ]
  default_network_acl_egress = [
    {
      "action"     = "allow",
      "from_port"  = 1024,
      "to_port"    = 65535,
      "protocol"   = "tcp",
      "cidr_block" = "0.0.0.0/0",
      "rule_no"    = 100
    },
    {
      "action"     = "allow",
      "from_port"  = 80,
      "to_port"    = 80,
      "protocol"   = "tcp",
      "cidr_block" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0]),
      "rule_no"    = 200
    },
    {
      "action"     = "allow",
      "from_port"  = 0,
      "to_port"    = 0,
      "protocol"   = "icmp",
      "icmp_code"  = -1,
      "icmp_type"  = -1,
      "cidr_block" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0]),
      "rule_no"    = 300
    }
  ]

  # define Security Groups
  default_security_group_name = "SG of VPC ${count.index + 1}"
  default_security_group_ingress = [
    {
      "description" = "SSH from Everywhere",
      "from_port"   = 22,
      "to_port"     = 22,
      "protocol"    = "tcp",
      "cidr_ipv4"   = "0.0.0.0/0"
    },
    {
      "description" = "HTTP between VPC 1 and 2",
      "from_port"   = 80,
      "to_port"     = 80,
      "protocol"    = "tcp",
      "cidr_ipv4"   = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0])
    },
    {
      "description" = "ICMP between VPC 1 and 2",
      "from_port"   = -1,
      "to_port"     = -1,
      "protocol"    = "icmp",
      "cidr_ipv4"   = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0])
    }
  ]
  default_security_group_egress = [
    {
      "from_port" = 0,
      "to_port"   = 0,
      "protocol"  = "-1",
      "cidr_ipv4" = "0.0.0.0/0"
    }
  ]

}

/*
# create VPC Peering Connection
resource "aws_vpc_peering_connection" "aNACHb" {
  depends_on  = [module.vpc]
  vpc_id      = vpc.vpc-0.vpc_id
  peer_vpc_id = vpc.vpc-1.vpc_id
  auto_accept = true
  tags = {
    Name = "VPC Peering aNACHb"
  }
}

# edit default route tables
resource "aws_default_route_table" "default-RT" {
  depends_on = [module.vpc]

  count = length(var.vpc_cidr_blocks)

  default_route_table_id = vpc.vpc-[count.index + 1].default_vpc_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = vpc.vpc-[count.index + 1].igw_id
  }
  route {
    cidr_block = "192.168.0.0/24"
    gateway_id = aws_vpc_peering_connection.aNACHb.id
  }
}

# create Instances in both VPCs
module "instances" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "> 5.1.0"

  count = length(var.vpc_cidr_blocks)

  name                        = "instance-vpc-${count.index + 1}"
  ami                         = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  subnet_id                   = vpc.vpc-[count.index + 1].public_subnets[0]
  associate_public_ip_address = true
  key_name                    = "ssh-september"
  tags = {
    Name = "instance-vpc-${count.index + 1}"
  }
  vpc_security_group_ids = [vpc.vpc-[count.index + 1].default_security_group_id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
  EOF
}

# create ENIs for both VPCs
resource "aws_network_interface" "enis" {
  depends_on      = [module.instances]
  count           = length(var.vpc_cidr_blocks)
  description     = "ENI for Subnet VPC-${count.index + 1}"
  subnet_id       = vpc.vpc-[count.index + 1].public_subnets[0]
  security_groups = [vpc.vpc-[count.index + 1].default_security_group_id]
  attachment {
    instance     = instances.instance-vpc-[count.index + 1].id
    device_index = 1
  }
}
*/