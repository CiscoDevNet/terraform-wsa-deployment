output "subnet_tenant_public" {
  value = data.aws_subnets.subnet_tenant_public.ids
}
output "eip" {
  value = aws_eip.eip.id
}
