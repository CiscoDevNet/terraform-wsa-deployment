
output "mgmt_sec_group" {
  //value = [aws_security_group.mgmt_sec_group[*].id]
   value = [ for v in aws_security_group.mgmt_sec_group : v.id]
}

/*output "sg_content" {
value = [ for s in toset(local.configData.SecurityGroups): [
          to_port = s.name

]
]
}*/

/*
output "sg_content" {
value = [ for s in toset(local.configData.SecurityGroups): [
          for j in s.Ingress: {
          to_port = j.to_port
}
]
]
}*/



