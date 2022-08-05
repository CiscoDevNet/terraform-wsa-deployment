

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Security Group with an ingress rule for the VPC cidr
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
data "aws_region" "current" {
}
resource "aws_security_group" "mgmt_sec_group" {
  name = "${var.swa_tenant}-${data.aws_region.current.name}-SG"
  description = "DEMO Security Group for testing purpose."
  vpc_id = var.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  tags = { 
	   Name = "Demo-Security-Group" 
	 }
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

