variable "region" {
  description = "AWS Region"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}
variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}
variable "subnet_cidr" {
  description = "CIDR for public subnets"
  type        = list(string)
}