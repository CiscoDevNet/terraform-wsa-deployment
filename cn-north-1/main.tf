terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
   }
 }
}

provider "aws" {
  region = "cn-north-1"
}

module "datacenter" {
  source = "./dc-prerequisite"
  vpc_name = var.vpc_name
  //vpc_id = module.dc-prerequisite.vpc_id
  vpc_cidr = var.vpc_cidr
  igw_name = var.igw_name
}

