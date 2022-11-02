variable "subnets" {
  type = set(string)
}

variable "iam_profile" {
  type = string
}

variable "sg_autoscaling" {
  type = set(string)
}

variable "nlb-eip" {
  type = list
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

variable "desired" {
  type = number
}


variable "listener_port" {
  type = number
}

variable "listener_protocol" {
  type = string
}

variable "tg_port" {
  type = number
}

variable "tg_protocol" {
  type = string
}

variable "tg_healthport" {
  type = string
}

variable "tg_healthprotocol" {
  type = string
}

variable "tg_healthpath" {
  type = string
}

variable "lb-listner" {
  type = list (object({ port = string, protocol  = string, tg = string }))
}

variable "lb_target_group" {
  type = list (object({ name = string, port = string,  protocol  = string,  healthcheck_port = string, healthcheck_protocol = string, healthcheck_path = string }))
}

/*variable "pac_target_group" {
  type = list (object({ name = string, port = string,  protocol  = string }))
}*/

variable "volume_termination" {
 type = string
 default = "true"
}

variable "dp_max_size" {
  type = string
  //default = 2
}

variable "dp_min_size" {
  type = string
  //default = 2
}

variable "dp_tg_port" {
  type = string
  default = "9001"
}
