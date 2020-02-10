# Launch configuration defines the Ec2 instances that will be started to support our cluster (instance type and AMI).
# On top of that, it:
# a) allows us do attach instance profile to each instance that will be started
# b) security group
# c) it sends user-defined data to EC2 instance. This data will be run as a script after instance will be booted up.
resource "aws_launch_configuration" "ecs-launch-config" {
  image_id = data.aws_ami.ecs-ami.id
  instance_type = var.instance_type
# Using AMI id in launch config name is a workaround for problems with recreating the autoscaling group
  name = "ecs-launch-config-${data.aws_ami.ecs-ami.id}"
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

  lifecycle {
    create_before_destroy = true
  }
  security_groups = [aws_security_group.ecs_test_sg.id]
  # Please attach public IP only if needed...
  associate_public_ip_address = "true"
  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
    EOF
}

# Thanks to autoscaling group we will be able to define how many EC2 instances we need
# define where (network-wise) instances should be started (subnets) and allows us to attach instances to LB target group
# attach launch configuration, define health check for our instances
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
# Using AMI id in launch config name is a workaround for problems with recreating the autoscaling group
  name = "ecs-autoscaling-group-${data.aws_ami.ecs-ami.id}"
  max_size = var.max_instances
  min_size = var.min_instances
  vpc_zone_identifier = aws_subnet.ecs_subnets.*.id
  launch_configuration = aws_launch_configuration.ecs-launch-config.name
# Use health_check_type = "EC2" if not using Elastic Load Balancer
  health_check_type = "ELB"
  # Dont use target group if not using ELB
  target_group_arns = [aws_lb_target_group.ecs-target-group-lb.arn]
}