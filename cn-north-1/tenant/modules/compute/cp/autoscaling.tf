##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource cretes an autoscaling launch template for the CONTROL PLANE - CP Instances of the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_launch_template" "wsa_autoscale" {
  name = "${var.lt_name}-lt"
  image_id = var.image_id
  instance_type = var.instance_type
  update_default_version = "true"
  vpc_security_group_ids = var.sg_autoscaling
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }
  iam_instance_profile {
    name = var.iam_profile
  }
  block_device_mappings {
    device_name = "/dev/sda1"
        ebs {
                volume_size = 200
                delete_on_termination = var.volume_termination
                encrypted = false
        }
     }
  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.lt_name}_volume"
    }
  }
}



##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--
#INFO: the following resource creates an AutoScaling Group for the CONTROL PLANE - CP Instances of the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--

data "aws_default_tags" "provider" {}

resource "aws_autoscaling_group" "autoscaled_group" {
  name = "${var.swa_tenant}-cp-ASG"
  desired_capacity   = var.desired
  max_size           = var.cp_max_size    //(+ 1)
  min_size           = var.cp_min_size     //(== 1 ? var.desired : var.desired - 1)
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
  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = data.aws_default_tags.provider.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  tag {
        key = "Name"
        value = var.lt_name
        propagate_at_launch = true
  }
  tag {
        key = "swa_role"
        value = var.swa_role
        propagate_at_launch = true
  }
  tag {
        key = "autoscaled_exp"
        value = true
        propagate_at_launch = true
  }  
}
