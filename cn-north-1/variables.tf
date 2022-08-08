variable "vpc_name" {
  type = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "igw_name" {
  type = string
  description = "IGW name used for the Internet gateway"
}
