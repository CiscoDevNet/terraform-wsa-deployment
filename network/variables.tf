variable "vpc_name" {
  type = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}


variable "vpc_id" {
  type = string
  description = "VPC ID used for the subnet"
}


variable "subnet_config" {
  type = list(object({name=string,cidr_block=string,availability_zone=string,is_public=bool,swa_tenant=string}))
  description = "Config for the subnet"
}

variable "igw_id" {
  type = string
  description = "IGW ID used for the route table"
}

variable "igw_name" {
  type = string
  description = "IGW name used for the Internet gateway"
}

variable "common_tags" {
  type = map(string)
  default = {
    "product" = "swa"
    "swatenant" = "dev"
  }
}
