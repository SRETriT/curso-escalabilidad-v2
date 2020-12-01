
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_launch_configuration" "this" {
  name_prefix   = "sre-lc-"
  image_id      = data.aws_ami.this.image_id
  instance_type = var.instance_size
  security_groups = [
    module.turnomatic_server_sg.this_security_group_id,
    module.turnomatic_server_sg_ssh.this_security_group_id
  ]
  lifecycle {
    create_before_destroy = true
  }
}


module "asg" {
  source                       = "terraform-aws-modules/autoscaling/aws"
  version                      = "~> 3.0"
  name                         = "Turnomatic"
  launch_configuration         = aws_launch_configuration.this.name
  create_lc                    = false
  recreate_asg_when_lc_changes = true
  # Auto scaling group
  asg_name                  = "sre-asg"
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "ELB"
  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "Curso SRE"
      propagate_at_launch = true
    },
  ]
  target_group_arns = module.nlb.target_group_arns

}


resource "aws_autoscaling_policy" "scale_up" {
  name                   = "turnomatic-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 100
  autoscaling_group_name = module.asg.this_autoscaling_group_name
}
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "turnomatic-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 200
  autoscaling_group_name = module.asg.this_autoscaling_group_name
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "turnomatic-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  

  dimensions = {
    AutoScalingGroupName = module.asg.this_autoscaling_group_name
  }

  alarm_description = "Scale up if CPU utilization is above 80% for 60 seconds"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "turnomatic-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    AutoScalingGroupName = module.asg.this_autoscaling_group_name
  }

  alarm_description = "Scale down if CPU utilization is below 80% for 60 seconds"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}
