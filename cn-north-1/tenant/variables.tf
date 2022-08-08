
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
/*
variable "subnet_config" {
  type = list(object({name=optional(string),cidr_block=string,availability_zone=string,is_public=optional(bool),swa_tenant=optional(string)}))
  description = "Configuration for the Subnets"
  default = [
     // {name="web-public-common1a", cidr_block="10.10.1.0/24",availability_zone="cn-north-1a", is_public=true},
     // {name="web-public-common1b", cidr_block="10.10.2.0/24",availability_zone="cn-north-1b", is_public=true},
     // {name="web-public-common1d", cidr_block="10.10.3.0/24",availability_zone="cn-north-1d", is_public=true},
     // {name="test-mgmt-common1a", cidr_block="10.0.100.0/24",availability_zone="cn-north-1a", is_public=true, swa_tenant = "cisco"},
     // {name="test-mgmt-common1b", cidr_block="10.0.101.0/24",availability_zone="cn-north-1b", is_public=true, swa_tenant = "cisco"},
     // {name="test-mgmt-common1d", cidr_block="10.0.102.0/24",availability_zone="cn-north-1d", is_public=true, swa_tenant = "cisco"}
 ]
}
*/

variable "swa_tenant" {
  type = string
}

variable "subnet_config" { 
  type = list(object({cidr_block = string, availability_zone = string}))
}



##########################
########## SECURITY GROUP
###########################


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


/*
variable "launch_config_dp" {
  type = list(object({lt_name=string, image_id=string, instance_type=string, key_name=string, desired=number, max=number, min=number, swa_tenant=string, swa_role=string}))
  default = [
        {lt_name="demo-dp",image_id="ami-0e15556243efd8f0b", instance_type="c5.xlarge",key_name="wsa-test-key",desired=3,max=4,min=2,swa_tenant="cisco", swa_role="data"},
        ]
}

variable "launch_config_cp" {
  type = list(object({lt_name=string, image_id=string, instance_type=string, key_name=string, desired=number, max=number, min=number, swa_tenant=string, swa_role=string}))
  default = [
        {lt_name="demo-cp",image_id="ami-0e15556243efd8f0b", instance_type="c5.xlarge",key_name="wsa-test-key",desired=3,max=4,min=2,swa_tenant="cisco", swa_role="control"},
        ]
}
*/

