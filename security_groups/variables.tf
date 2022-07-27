variable "aws_vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "aws_proxy_sgname" {
  description = "Name of the PROXY security group to create"
  type        = string
}
variable "aws_mgmt_sgname" {
  description = "Name of the MGMT security group to create"
  type        = string
}


