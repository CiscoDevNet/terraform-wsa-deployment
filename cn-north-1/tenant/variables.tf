
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

variable "env" {
  type = string
}


########################
###Upgrade
########################

variable "lb-listner" {
  type = list (object({ port = string, protocol  = string, tg = string }))
}


variable "lb_target_group" {
   type = list (object({ name = string, port = string,  protocol  = string,  healthcheck_port = string, healthcheck_protocol = string, healthcheck_path = string }))
   default = [{
     name = "proxy",
     port = "3128",
     protocol = "TCP",
     healthcheck_port = "4431",
     healthcheck_protocol = "HTTPS",
     healthcheck_path = "/wsa/api/v3.0/healthcheck_services/aws_healthcheck"
},
     {
     name = "pac",
     port = "9001",
     protocol = "TCP",
     healthcheck_port = "4431",
     healthcheck_protocol = "HTTPS",
     healthcheck_path = "/wsa/api/v3.0/healthcheck_services/aws_healthcheck"
} 
	]
}

