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

  # Internet Gateway
  create_igw = true

  # Defaults
  manage_default_network_acl = true

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
      "cidr_block" = "0.0.0.0/0"
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
}

# define Security Groups
module "sg" {
  source     = "terraform-aws-modules/security-group/aws"
  version    = ">= 5.1.0"
  depends_on = [module.vpc]

  count       = length(var.vpc_cidr_blocks)
  vpc_id      = module.vpc.*.vpc_id[count.index]
  description = "SG of Instances in VPC ${count.index + 1}, ssh from everywhere, http and ping between VPC 1 and 2"
  name        = "SG of VPC ${count.index + 1}"

  create_sg = true

  ingress_with_cidr_blocks = [
    {
      "description" = "SSH from Everywhere",
      "from_port"   = 22,
      "to_port"     = 22,
      "protocol"    = "tcp",
      "cidr_blocks" = "0.0.0.0/0"
    },
    {
      "description" = "HTTP between VPC 1 and 2",
      "from_port"   = 80,
      "to_port"     = 80,
      "protocol"    = "tcp",
      "cidr_blocks" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0])
    },
    {
      "description" = "ICMP between VPC 1 and 2",
      "from_port"   = -1,
      "to_port"     = -1,
      "protocol"    = "icmp",
      "cidr_blocks" = (count.index == 0 ? var.vpc_cidr_blocks[1] : var.vpc_cidr_blocks[0])
    }
  ]
  egress_with_cidr_blocks = [
    {
      "from_port"   = 0,
      "to_port"     = 0,
      "protocol"    = "-1",
      "cidr_blocks" = "0.0.0.0/0"
    }
  ]
}

# create VPC Peering Connection
resource "aws_vpc_peering_connection" "From_1_to_2" {
  depends_on  = [module.vpc]
  vpc_id      = module.vpc.*.vpc_id[0]
  peer_vpc_id = module.vpc.*.vpc_id[1]
  auto_accept = true
  tags = {
    Name = "VPC Peering From 1 to 2"
  }
}

# edit default route tables
resource "aws_default_route_table" "RT" {
  depends_on = [module.vpc]

  count = length(var.vpc_cidr_blocks)

  default_route_table_id = module.vpc.*.default_route_table_id[count.index]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.*.igw_id[count.index]
  }
  route {
    cidr_block = var.vpc_cidr_blocks[count.index == 0 ? 1 : 0]
    gateway_id = aws_vpc_peering_connection.From_1_to_2.id
  }
}

# create Instances in both VPCs
module "instances" {
  depends_on = [module.sg]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "> 5.1.0"

  count = length(var.vpc_cidr_blocks)

  name                        = "instance-vpc-${count.index + 1}"
  ami                         = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.*.public_subnets[count.index][0]
  associate_public_ip_address = true
  key_name                    = "ssh-september"
  tags = {
    Name = "instance-vpc-${count.index + 1}"
  }
  vpc_security_group_ids = [module.sg.*.security_group_id[count.index]]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
  EOF
}

# create ENIs for both VPCs
resource "aws_network_interface" "enis" {
  depends_on = [module.instances]
  count      = length(var.vpc_cidr_blocks)

  description = "ENI for Subnet VPC-${count.index + 1}"

  subnet_id       = module.vpc.*.public_subnets[count.index][0]
  security_groups = [module.vpc.*.default_security_group_id[count.index]]
  attachment {
    instance     = module.instances.*.id[count.index]
    device_index = 1
  }
}