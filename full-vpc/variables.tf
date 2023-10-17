variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}
variable "azs" {
  description = "availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "vpc_cidr" {
  description = "Data for VPC "
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR Blocks for subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidr" {
  description = "CIDR Blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
