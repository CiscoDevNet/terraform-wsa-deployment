##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following data block pics up those Subnets from the list that are specific to our VPC and have the SWA-Tenant tag
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--####--##--##--##--##--

locals {
  subnet_ids = tolist(var.subnets)
  aid_emptylist = [for k in var.subnets: ""]
  allocation_ids = length(var.nlb-eip) == 0 ? local.aid_emptylist : tolist(var.nlb-eip)
  subnets_eip = [
    for sid,aid in zipmap(local.subnet_ids,local.allocation_ids) : {
      subnet_id = sid
      allocation_id = aid
   }
 ]
}
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the NetworkLoadBalancer using the subnet filtered above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_lb" "swa_nlb" {
  name               = "${var.swa_tenant}-NLB"
  internal           = false
  load_balancer_type = "network"
  dynamic "subnet_mapping" {
    for_each = local.subnets_eip
    content {
      subnet_id = subnet_mapping.value["subnet_id"]
      allocation_id = subnet_mapping.value["allocation_id"]
    }
  }
  enable_cross_zone_load_balancing = false
  enable_deletion_protection = false

}



##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block create a Target Group for the NLB created above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_lb_target_group" "swa_tg" {
  name        = "${var.swa_tenant}-${var.lb_target_group[count.index].name}-TG"
  count = length(var.lb_target_group)
  port        = var.lb_target_group[count.index].port
  protocol    = var.lb_target_group[count.index].protocol
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
     protocol = var.lb_target_group[count.index].healthcheck_protocol
     path = var.lb_target_group[count.index].healthcheck_path
     port = var.lb_target_group[count.index].healthcheck_port
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
       swa_tgtype =  var.lb_target_group[count.index].name
  }
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Listeners for the NLB creaed above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_lb_listener" "k3s_lb_http" {
  count = length(var.lb-listner)
  load_balancer_arn = aws_lb.swa_nlb.id
  protocol = var.lb-listner[count.index].protocol
  port = var.lb-listner[count.index].port
  default_action {
      type             = "forward"
      target_group_arn = var.lb-listner[count.index].tg == "pac" ? aws_lb_target_group.swa_tg[1].arn : aws_lb_target_group.swa_tg[0].arn
  }
}

 
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO : the following resource create the AutoScaling Launch Template for the DATA PLANE Instances for the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_launch_template" "wsa_autoscale" {
  name = "${var.lt_name}-lt"                   // "swa-cp-autoscale-test"
  image_id = var.image_id               //"ami-0ecb92ab16b149e5f"
  instance_type = var.instance_type     //"c5.2xlarge"
  ##key_name = var.key_name               //"wsa-test-key"
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


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO : the following resource create the AutoScaling Group for the DATA PLANE Instances for the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

data "aws_default_tags" "provider" {}

resource "aws_autoscaling_group" "autoscaled_group" {
  name = "${var.swa_tenant}-dp-ASG"
  desired_capacity   = var.desired
  max_size           = var.dp_max_size     //(+ 1)
  min_size           = var.dp_min_size     //(== 1 ? var.desired : var.desired - 1)
  health_check_type = "ELB"
  health_check_grace_period = 600
  target_group_arns = aws_lb_target_group.swa_tg[*].arn   ############  NEW Addition to the DP autoscale only
  launch_template {
    id = aws_launch_template.wsa_autoscale.id
    version = aws_launch_template.wsa_autoscale.latest_version
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
        key = "name"
        value = var.lt_name
        propagate_at_launch = true
  }
  tag {
        key = "swa_role"
        value = var.swa_role
        propagate_at_launch = true
  }
  tag {
        key = "autocaled_exp"
        value = true
        propagate_at_launch = true
  }
 
}
