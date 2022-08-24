##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following data block pics up those Subnets from the list that are specific to our VPC and have the SWA-Tenant tag
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--####--##--##--##--##--

data "aws_subnets" "subnets_mgmt_public" {
  filter {
          name = "vpc-id"
          values= [var.vpc_id]
  }
   tags = {
     swa_tenant = var.swa_tenant
   }
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the NetworkLoadBalancer using the subnet filtered above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_lb" "swa_nlb" {
  name               = "${var.swa_tenant}-NLB"
  internal           = false
  load_balancer_type = "network"
  //subnets            = [for subnet in data.aws_subnets.subnets_mgmt_public.ids : subnet]
  subnets  = data.aws_subnets.subnets_mgmt_public.ids
  enable_cross_zone_load_balancing = false
  enable_deletion_protection = false
/*
  tags = merge(
        var.common_tags,
        {
                "Environment"="DEV"
        },
        )*/
}



##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block create a Target Group for the NLB created above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_lb_target_group" "swa_tg" {
  name        = "${var.swa_tenant}-TG"
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
     port     = var.healthtcheck_port
     protocol = var.healthtcheck_protocol
  }

  lifecycle {
    create_before_destroy = true
  }
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the Listeners for the NLB creaed above
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_lb_listener" "k3s_lb_http" {
  load_balancer_arn = aws_lb.swa_nlb.id
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    target_group_arn = aws_lb_target_group.swa_tg.id
    type             = "forward"
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
   		delete_on_termination = false
                encrypted = true
 	}
     }	
  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.lt_name}-volume"
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
  max_size           = var.desired     //(+ 1)
  min_size           = var.desired     //(== 1 ? var.desired : var.desired - 1)
  health_check_type = "ELB"
  health_check_grace_period = 600
  target_group_arns = [ aws_lb_target_group.swa_tg.arn ]   ############  NEW Addition to the DP autoscale only
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

  /*
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 30
    }
    triggers = ["tag"]
  }*/
  
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
        key = "SWARole"
        value = var.swa_role
        propagate_at_launch = true
  }
  tag {
        key = "autoScaledExp"
        value = true
        propagate_at_launch = true
  }
 
}

