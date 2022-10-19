variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "sg_name" {
  type = string
}
variable "swa_tenant" {
  type = string
}

variable "subnets" {
  type = set(string)
}


