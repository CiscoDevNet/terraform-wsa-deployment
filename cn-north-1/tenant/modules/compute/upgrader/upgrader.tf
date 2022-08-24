resource "aws_instance" "upgrader"{
  vpc_security_group_ids = var.sg_autoscaling
  iam_instance_profile = var.iam_profile
  ami = var.image_id
  subnet_id   = tolist(var.subnets)[0]
  instance_type = var.instance_type 
  tags = {
    SWARole = "upgrader"
    version = var.upgrade_version
    Name = "${var.swa_tenant}-upgrader"
 } 
}


/*
resource "aws_network_interface" "upgrade_interface" {
  subnet_id   = tolist(var.subnets)[1]
  security_groups = var.sg_autoscaling
  tags = {
    Name = "upgrade_network_interface"
  }
}*/
