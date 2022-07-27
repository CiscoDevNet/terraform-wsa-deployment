###################
######  VPC  ######
###################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the new VPC
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = var.vpc_name
  }
}

############################
######    SUBNETS     ######
############################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the new Subnets depending upon how many are passed from main.tf
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_subnet" "subnet" {
  count = length(var.subnet_config)
  tags = {
      Name = var.subnet_config[count.index].name
      swa_tenant = var.subnet_config[count.index].swa_tenant
  }
  cidr_block = var.subnet_config[count.index].cidr_block
  availability_zone = var.subnet_config[count.index].availability_zone
  vpc_id = var.vpc_id
  map_public_ip_on_launch = var.subnet_config[count.index].is_public

}

###############################
###### INTERNET--GATEWAY ######
###############################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the InternetGateway and attached it to the VPC
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_internet_gateway" "swa_igw" {
  vpc_id = var.vpc_id
  tags = {
  	Name = var.igw_name
  }
}


#########################
###### ROUTE-TABLE ######
#########################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Route Table for the VPC
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_route_table" "swa_route" {
  depends_on = [
	aws_internet_gateway.swa_igw
  ]
  vpc_id = var.vpc_id
  route {
  	cidr_block = "0.0.0.0/0"
  	gateway_id = var.igw_id
  }
}

data "aws_subnets" "subnets_mgmt_public" {
  depends_on = [
	aws_subnet.subnet
  ]
        filter {
                name = "vpc-id"
                values= [var.vpc_id]
        }
   tags = {
     Name = "*mgmt*"
   }
}



data "aws_subnets" "subnets_web_public" {
  depends_on = [
    aws_subnet.subnet
  ]
        filter {
                name = "vpc-id"
                values= [var.vpc_id]
        }
   tags = {
     Name = "*web*"
   }
}


##############################################
########## ROUTE-TABLE ASSOCIATION ###########
##############################################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the RouteTable Association, and attaches above created subnets to this.
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_route_table_association" "rt_associate_public" {
    depends_on = [ aws_subnet.subnet ]
    count = length(aws_subnet.subnet.*.id)
    subnet_id = element(aws_subnet.subnet.*.id, count.index)
    //count = length(data.aws_subnets.subnets_mgmt_public.*.ids)
    //subnet_id = for subnet in data.aws_subnets.subnets_mgmt_public.ids : subnet
    //subnet_id = data.aws_subnets.subnets_mgmt_public.ids[count.index]
    //subnet_id= data.aws_subnets.subnets_mgmt_public[count.index].id
    route_table_id = aws_route_table.swa_route.id
}


