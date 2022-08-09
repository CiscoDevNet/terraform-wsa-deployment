variable "subnets" {
  type = set(string)

}

variable "iam_profile" {
  type = string
}

variable "sg_autoscaling" {
  type = set(string)
}

variable "swa_tenant" {
  type = string
}

variable "vpc_id" {
  type = string
  description = "VPC ID used for the subnet"
}

variable "swa_role" {
  type = string
}

variable "lt_name" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

##variable "key_name" {
##  type = string
##}

variable "desired" {
  type = number
}

variable "healthtcheck_port" {
  type    = string
  default = "8443"
}

variable "healthtcheck_protocol" {
  type    = string
  default = "HTTPS"
}

variable "listener_port" {
  type    = string
  default = "3128"
}

variable "listener_protocol" {
  type    = string
  default = "TCP"
}

variable "tg_port" {
  type    = string
  default = "3128"
}

variable "tg_protocol" {
  type    = string
  default = "TCP"
}
