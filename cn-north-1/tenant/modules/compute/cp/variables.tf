variable "subnets" {
  type = set(string)

}

variable "iam_profile" {
  type = string
}

variable "sg_autoscaling" {
  type = set(string)
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

variable "desired" {
  type = number
}

variable "swa_tenant" {
 type = string
}

variable "volume_termination" {
 type = string
 default = "true"
}

variable "cp_max_size" {
  type = string
}

variable "cp_min_size" {
  type = string
}
