#fourth step

# ELB will sit in front of our instances to balance traffic between running EC2 instances
resource "aws_lb" "ecs-load-balancer" {
  load_balancer_type = "application"
  name = "ecs-lb"
  security_groups = [aws_security_group.ecs_test_sg.id]
  subnets = aws_subnet.ecs_subnets.*.id
  tags = {
    name = "ecs-application-load-balancer"
  }
}

# target group with health_check
resource "aws_lb_target_group" "ecs-target-group-lb" {
  name = "ecs-target-group"
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.ecs_test.id
  depends_on = [aws_lb.ecs-load-balancer]
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
 }
  tags = {
    Name = "ecs-target-group-lb"
  }
}

# We need a listener to be able to connect to LB
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.ecs-load-balancer.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs-target-group-lb.arn
  }
}


