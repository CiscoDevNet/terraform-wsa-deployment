
variable "vpc_id" {
  type = string
}

##################
### IAM Variables
##################

## NO VARIABLES REQUIRED FOR IAM MODULE


########################
######  NETWORK variables
########################
variable "swa_tenant" {
  type = string
}

variable "subnet_config" { 
  type = list(object({cidr_block = string, availability_zone = string}))
}

variable "swa_domain" {
  type = string
}

variable "upgrade_version" {
  type = string
}
##############################
########## SECURITY GROUP
##############################

variable "sg_name" {
  type = string
  default = "sg_demo"
}

#############################
######  AUTOSCALING VARIABLES
#############################

variable "launch_config_dp" {
  type = list (object( { ami_id = string, instance_type = string, desired = number }))
}
variable "launch_config_cp" {
  type = list (object({ ami_id = string, instance_type = string, desired = number}))
}

########################
###Upgrade
########################

variable "tg_healthport" {
  type = string
  default =  "4431"
}

variable "env" {
  type = string
}

variable "tg_healthprotocol" {
  type = string
  default = "HTTPS"
}

variable "tg_healthpath" {
  type = string
  default = "/wsa/api/v3.0/healthcheck_services/aws_healthcheck"
}

variable "listener_port" {
  type = number
  default = 3128
}

variable "listener_protocol" {
  type = string
  default = "TCP"
}

variable "tg_port" {
  type = number
  default = 3128
}

variable "tg_protocol" {
  type = string
  default = "TCP"
}

variable "lb-listner" {
  type = list (object({ port = string, protocol  = string}))
}
