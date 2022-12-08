terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  default_tags {
   tags = {
    product = "swa"
    swa_deployment = "cluster"
    swa_tenant = var.swa_tenant
    swa_domain = var.swa_domain
   }
 }
}

module "s3" {
  source = "./tenant-prerequisite"
  swa_tenant = var.swa_tenant
}


module "network" {
  source = "./modules/network"
  vpc_id = var.vpc_id
  subnets = module.network.subnet_tenant_public
  env = var.env
  subnet_config = var.subnet_config
  swa_tenant = var.swa_tenant
}

module "iam" {
  source = "./modules/IAM"
  swa_tenant = var.swa_tenant
  bucket_arn = module.s3.bucket_arn
  dynamodb_arn = module.DB.dynamodb_arn
  arn = module.DB.arn
}

module "DB" {
  source = "./modules/DB"
  swa_tenant = var.swa_tenant
}


############################
############# SECURITY GROUP
############################

data "aws_vpc" "vpc_cidr" {
  id = var.vpc_id
}

output "vpc_cidr_from_data" {
  value = data.aws_vpc.vpc_cidr.cidr_block_associations[0].cidr_block
}


module "security_group" {
  source = "./modules/securitygroups"
  vpc_id = var.vpc_id
  swa_tenant = var.swa_tenant
  vpc_cidr = data.aws_vpc.vpc_cidr.cidr_block_associations[0].cidr_block
  sg_name = var.sg_name
  subnets = module.network.subnet_tenant_public

}


module "autoscaling_cp" {
  source = "./modules/compute/cp"
  depends_on = [ module.security_group ]
  count = length(var.launch_config_cp)
  subnets = module.network.subnet_tenant_public
  iam_profile = module.iam.ec2_profile
  sg_autoscaling = module.security_group.mgmt_sec_group
  lt_name = "${var.swa_tenant}-cp"
  image_id = var.launch_config_cp[count.index].ami_id
  desired = var.launch_config_cp[count.index].desired
  instance_type = var.launch_config_cp[count.index].instance_type
  swa_tenant = var.swa_tenant
  swa_role = "control"
  vpc_id = var.vpc_id
  cp_max_size = var.launch_config_cp[count.index].desired
  cp_min_size = var.launch_config_cp[count.index].desired
}

/*module "monitoring" {
  source = "./modules/monitoring"
  swa_tenant = var.swa_tenant
}*/

