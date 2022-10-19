
data "aws_region" "current" {
}


data "local_file" "getJsonFile" {

    filename = "security.json"

}

locals {    

    configData = jsondecode(data.local_file.getJsonFile.content)
    security_groups = jsondecode(file("security.json"))["SecurityGroups"]
}


resource "aws_security_group" "mgmt_sec_group" {
  for_each = { for index, sg in toset(local.security_groups) : sg.name => sg }
     name = "${var.swa_tenant}-${data.aws_region.current.name}-${each.value.name}" 
     vpc_id = var.vpc_id
     dynamic "ingress"{
        for_each = each.value.Ingress
          content  {
             to_port = ingress.value["to_port"]
             from_port = ingress.value["from_port"]
             protocol = ingress.value["protocol"]
             cidr_blocks = (ingress.value["cidr_blocks"][0] != "vpc_cidr" ? ingress.value["cidr_blocks"] : ["${var.vpc_cidr}"])
      }
}
 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


