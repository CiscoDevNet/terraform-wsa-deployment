######## Get current region ############
data "aws_region" "current" {}

###### VPC #############
resource "aws_vpc" "swa_vpc" {
  count = var.vpc_name != "" ? 1 : 0 
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = var.vpc_name
  }
}

###### INTERNET--GATEWAY ######

resource "aws_internet_gateway" "swa_igw" {
  count = var.igw_name != "" ? 1 : 0
  vpc_id = data.aws_vpc.selected_vpc[0].id
  tags = {
        Name = var.igw_name
  }
}

data "aws_vpc" "selected_vpc" {
  depends_on = [
	aws_vpc.swa_vpc
]
  count = var.vpc_cidr != "" ? 1 : 0
  cidr_block = var.vpc_cidr
}
