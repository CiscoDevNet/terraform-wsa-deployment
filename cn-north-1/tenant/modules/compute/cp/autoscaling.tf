##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource cretes an autoscaling launch template for the CONTROL PLANE - CP Instances of the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_launch_template" "wsa_autoscale" {
  name = "${var.lt_name}-lt"
  image_id = var.image_id
  instance_type = var.instance_type
  ##key_name = var.key_name
  update_default_version = "true"
  vpc_security_group_ids = var.sg_autoscaling
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  iam_instance_profile {
    name = var.iam_profile
  }
}



##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
#INFO: the following resource creates an AutoScaling Group for the CONTROL PLANE - CP Instances of the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--


resource "aws_autoscaling_group" "autoscaled_group" {
  name = "${var.swa_tenant}-cp-ASG"
  //availability_zones = "cn-north-1a", "cn-north-1b","cn-north-1d"]
  desired_capacity   = var.desired
  max_size           = var.desired + 1
  min_size           = var.desired == 1 ? var.desired : var.desired - 1
  launch_template {
    id = aws_launch_template.wsa_autoscale.id
    version = "$Latest"
  }
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  vpc_zone_identifier = var.subnets
  /*initial_lifecycle_hook {
    name                 = "attachcpSecondaryNic"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 60
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }*/
  lifecycle {
    create_before_destroy = true
  }
  tag {
        key = "Name"
        value = var.lt_name
        propagate_at_launch = true
  }
  tag {
        key = "Product"
        value = "swa"
        propagate_at_launch = true
  }
  tag {
        key = "SWADeployment"
        value = "cluster"
        propagate_at_launch = true
  }
  tag {
        key = "SWARole"
        value = var.swa_role
        propagate_at_launch = true
  }
  tag {
        key = "SWATenant"
        value = var.swa_tenant
        propagate_at_launch = true
  }
   tag {
        key = "autoScaledExp"
        value = true
        propagate_at_launch = true
  }
}
