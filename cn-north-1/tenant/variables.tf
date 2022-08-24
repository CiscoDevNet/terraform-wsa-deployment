
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

variable "upgrade" {
  type = number
  default = 0
}
