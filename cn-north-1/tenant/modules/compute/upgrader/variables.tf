variable "subnets" {
  type = set(string)

}
variable "iam_profile" {
  type = string
}

variable "sg_autoscaling" {
  type = set(string)
  //type = string
}

variable "swa_tenant" {
  type = string
}
variable "swa_role" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "upgrade_version" {
  type = string
}
