

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Security Group with an ingress rule for the VPC cidr
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_security_group" "mgmt_sec_group" {
  name = var.aws_mgmt_sgname
  description = "SG for mgmt"
  vpc_id = var.aws_vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  tags = { Name = "mgmt_sec_group" }
}

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Security Group Rule for the Egress
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_security_group_rule" "allow_outbound_mgmt" {
  type              = "egress"
  security_group_id = aws_security_group.mgmt_sec_group.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


