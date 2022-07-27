
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
  enable_cross_zone_load_balancing = true
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
  port        = 3128
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    port     = 8443
    protocol = "HTTPS"
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
  port              = "3128"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.swa_tg.id
    type             = "forward"
  }
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO : the following resource create the AutoScaling Launch Template for the DATA PLANE Instances for the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_launch_template" "wsa_autoscale" {
  name = var.lt_name                    // "swa-cp-autoscale-test"
  image_id = var.image_id               //"ami-0ecb92ab16b149e5f"
  instance_type = var.instance_type     //"c5.2xlarge"
  key_name = var.key_name               //"wsa-test-key"
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



##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO : the following resource create the AutoScaling Group for the DATA PLANE Instances for the cluster
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_autoscaling_group" "autoscaled_group" {
  name = "${aws_launch_template.wsa_autoscale.name}-asg"
  //availability_zones = ["cn-north-1a", "cn-north-1b","cn-north-1d"]
  desired_capacity   = var.desired
  max_size           = var.max
  min_size           = var.min
  health_check_type = "ELB"
  target_group_arns = [ aws_lb_target_group.swa_tg.arn ]   ############  NEW Addition to the DP autoscale only
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
  initial_lifecycle_hook {
    name                 = "attachcpSecondaryNic"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 60
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
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

