
output "mgmt_sec_group" {
   value = [ for v in aws_security_group.mgmt_sec_group : v.id]
}

