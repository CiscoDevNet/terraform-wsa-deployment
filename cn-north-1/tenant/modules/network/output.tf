output "subnet_tenant_public" {
  value = data.aws_subnets.subnet_tenant_public.ids
}

output "nlb-eip" {
  value = tolist([ for v in aws_eip.nlb-eip : v.allocation_id])
}

