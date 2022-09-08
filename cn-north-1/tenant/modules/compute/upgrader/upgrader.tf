data "aws_default_tags" "provider" {}

data "aws_security_group" "selected" {
   tags = {
      SWATenant = var.swa_tenant
      //Name = var.sg_autoscaling
 }
}


resource "aws_instance" "upgrader"{
  //security_groups = var.sg_autoscaling
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  iam_instance_profile = var.iam_profile
  ami = var.image_id
  subnet_id   = tolist(var.subnets)[0]
  instance_type = var.instance_type 
  tags = {
    SWARole = "upgrader"
    SWAUpgradeVersion = var.upgrade_version
    Name = "${var.swa_tenant}-upgrader"
 }
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  volume_tags = merge(
    data.aws_default_tags.provider.tags,
    {
      Name = "${var.swa_tenant}-upgrader-volume"
    }
  )
}

/*resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = data.aws_security_group.selected.id
  network_interface_id = aws_instance.upgrader.primary_network_interface_id
}*/
