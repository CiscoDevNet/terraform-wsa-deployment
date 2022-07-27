
output "vpc_id" {
  value = aws_vpc.my_vpc.id

}
/*
output "vpc_cidr" {
  value = aws_vpc.my_vpc.
}
*/
output "igw_id" {
  value = aws_internet_gateway.swa_igw.id
}

output "subnets_id" {
  value = aws_subnet.subnet.*.id
}

output "mgmt_subnets" {
  value = data.aws_subnets.subnets_mgmt_public.ids
}


output "web_subnets_id" {
  value = data.aws_subnets.subnets_web_public.ids
}
