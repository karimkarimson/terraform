variable "vpc_cidr_blocks" {
  description = "CIDR blocks for VPCs."
  type        = list(string)
  default = [
    "10.0.0.0/24",
    "192.168.0.0/24"
  ]
}