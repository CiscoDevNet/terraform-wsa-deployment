data "aws_default_tags" "provider" {}

/*data "aws_security_group" "selected" {
   tags = {
      swa_tenant = var.swa_tenant
 }
}*/


resource "aws_instance" "upgrader"{
  //vpc_security_group_ids = [data.aws_security_group.selected.id]
  vpc_security_group_ids = var.sg_autoscaling
  iam_instance_profile = var.iam_profile
  ami = var.image_id
  subnet_id   = tolist(var.subnets)[0]
  instance_type = var.instance_type 
  tags = {
    swa_role = "upgrader"
    swa_upgrade_version = var.upgrade_version
    Name = "${var.swa_tenant}_upgrader"
 }
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  volume_tags = merge(
    data.aws_default_tags.provider.tags,
    {
      Name = "${var.swa_tenant}_upgrader_volume"
    }
  )
}
