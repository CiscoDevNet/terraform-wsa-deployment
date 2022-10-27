############################
######    SUBNETS     ######
############################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the new Subnets depending upon how many are passed from main.tf
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_subnet" "subnet" {
  count = length(var.subnet_config)
  tags = {
      Name = "${var.swa_tenant}_${var.subnet_config[count.index].availability_zone}-subnet"
  }
  cidr_block = var.subnet_config[count.index].cidr_block
  availability_zone = var.subnet_config[count.index].availability_zone
  vpc_id = var.vpc_id
  map_public_ip_on_launch = "true"

}


#########################
###### ROUTE-TABLE ######
#########################
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Route Table for the VPC
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##



data "aws_internet_gateway" "wsa_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_region" "current_region" {
}

resource "aws_route_table" "swa_route" {
  vpc_id = var.vpc_id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(split("/", data.aws_internet_gateway.wsa_igw.arn),1)}"
  }
  tags = { "Name" = "${var.swa_tenant}_${data.aws_region.current_region.name}-RT" }
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
    route_table_id = aws_route_table.swa_route.id
}

resource "aws_eip" "eip" {
  tags = { "Name" = "${var.swa_tenant}-cp-eip" }
}


####################
#####	Data Block
####################

data "aws_subnets" "subnet_tenant_public" {
  depends_on = [
        aws_subnet.subnet
  ]
        filter {
                name = "vpc-id"
                values= [var.vpc_id]
        }
   tags = {
     swa_tenant = var.swa_tenant
   }
}


resource "aws_eip" "nlb-eip" {
  depends_on = [
  aws_subnet.subnet
  ]
  count = var.env == "prod" ? length(var.subnet_config) : 0
  vpc = true

  tags = {
    Name = "${var.swa_tenant}-nlb-${count.index + 1}-eip"
 }
}

