variable "subnet_config" {
  type = list(object({cidr_block = string, availability_zone = string}))
}

variable "vpc_id" {
  type = string
}

variable "swa_tenant" {
  type = string
}

variable "subnets" {
  type = set(string)

}

variable "env" {
  type = string
}

