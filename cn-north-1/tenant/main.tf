terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      ##version = "~> 3.72"
    }
  }
}

provider "aws" {
  region = "cn-north-1"
}




module "s3" {
  source = "./tenant-prerequisite"
  swa_tenant = var.swa_tenant
}


module "network" {
  source = "./modules/network"
  vpc_id = var.vpc_id
  subnet_config = var.subnet_config
  swa_tenant = var.swa_tenant
}







module "iam" {
  source = "./modules/IAM"
  swa_tenant = var.swa_tenant
  bucket_arn = module.s3.bucket_arn
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
  swa_tenant=var.swa_tenant
  vpc_cidr = data.aws_vpc.vpc_cidr.cidr_block_associations[0].cidr_block
  sg_name = var.sg_name
}





module "autoscaling_dp" {
  depends_on = [ module.network ]
  source = "./modules/compute/dp"
  count = length(var.launch_config_dp)
  subnets = module.network.subnet_tenant_public
  iam_profile = module.iam.ec2_profile
  sg_autoscaling = [module.security_group.mgmt_sec_group]
  lt_name = "${var.swa_tenant}-dp"
  image_id = var.launch_config_dp[count.index].ami_id
  instance_type = var.launch_config_dp[count.index].instance_type
  ##key_name = var.launch_config_dp[count.index].key_name
  desired = var.launch_config_dp[count.index].desired
  swa_tenant = var.swa_tenant
  swa_role = "data"
  vpc_id = var.vpc_id
}


module "autoscaling_cp" {
  source = "./modules/compute/cp"
  count = length(var.launch_config_cp)
  subnets = module.network.subnet_tenant_public
  iam_profile = module.iam.ec2_profile
  sg_autoscaling = [module.security_group.mgmt_sec_group]
  lt_name = "${var.swa_tenant}-cp"
  image_id = var.launch_config_cp[count.index].ami_id
  desired = var.launch_config_cp[count.index].desired
  instance_type = var.launch_config_cp[count.index].instance_type
  ## key_name = var.launch_config_cp[count.index].key_name
  swa_tenant = var. swa_tenant
  swa_role = "control"
  vpc_id = var.vpc_id
}






###########################################################  Commenting for NOW
/*

data "aws_vpc" "vpc_cidr" {
  ##id = module.network.vpc_id
  id = var.vpc_id
}

output "vpc_cidr_from_data" {
  value = data.aws_vpc.vpc_cidr.cidr_block_associations[0].cidr_block
}


module "security_group" {
  source = "./modules/security_groups"
###########check in this line:::::  aws_vpc_id = module.network.vpc_id
###########  vpc_cidr = data.aws_vpc.vpc_cidr.cidr_block_associations[0].cidr_block
  aws_proxy_sgname = var.aws_proxy_sgname
  aws_mgmt_sgname = var.aws_mgmt_sgname
}


module "autoscaling_dp" {
  depends_on = [ module.network ]
  source = "./modules/compute/dp"
  count = length(var.launch_config_dp)
  subnets = module.network.mgmt_subnets
  iam_profile = module.iam.ec2_profile
  sg_autoscaling = [module.security_group.mgmt_sec_group]
  lt_name = var.launch_config_dp[count.index].lt_name
  image_id = var.launch_config_dp[count.index].image_id
  instance_type = var.launch_config_dp[count.index].instance_type
  ##key_name = var.launch_config_dp[count.index].key_name
  desired = var.launch_config_dp[count.index].desired
  max = var.launch_config_dp[count.index].max
  min = var.launch_config_dp[count.index].min
  //swa_tenant = var.swa_tenant
  swa_tenant = var.launch_config_dp[count.index].swa_tenant
  swa_role = var.launch_config_dp[count.index].swa_role
###########  vpc_id = module.network.vpc_id
}

module "autoscaling_cp" {
  source = "./modules/compute/cp"
  count = length(var.launch_config_cp)
  subnets = module.network.mgmt_subnets
  iam_profile = module.iam.ec2_profile
  sg_autoscaling = [module.security_group.mgmt_sec_group]
  lt_name = var.launch_config_cp[count.index].lt_name
  image_id = var.launch_config_cp[count.index].image_id
  instance_type = var.launch_config_cp[count.index].instance_type
  ## key_name = var.launch_config_cp[count.index].key_name
  desired = var.launch_config_cp[count.index].desired
  max = var.launch_config_cp[count.index].max
  min = var.launch_config_cp[count.index].min
  swa_tenant = var.launch_config_cp[count.index].swa_tenant
  swa_role = var.launch_config_cp[count.index].swa_role
###########  vpc_id = module.network.vpc_id
}

*/

