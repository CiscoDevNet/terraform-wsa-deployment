
output "mgmt_sec_group" {
  value = aws_security_group.mgmt_sec_group.id
}


/*
output "mgmt_sg" {
  value = aws_security_group.mgmtSG.id
}

output "proxy_sg" {
  value = aws_security_group.proxySG.id
}
*/
