# Yes, the cluster itself is that simple :)
resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.ecs_cluster
}

# Task is more complex :)
resource "aws_ecs_task_definition" "esc_test_task" {
  family = "ecs-testing"
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn = aws_iam_role.ecs-task.arn
  container_definitions = <<DEFINITION
[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu" : 1024,
    "memory" : 800,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      {
        "Name": "AWS_DEFAULT_REGION",
        "Value": "eu-central-1"
      },
      {
        "Name": "AWESOME_VAR",
        "Value": "AWESOME_VALUE_1"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/test-cluster",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "awslogs-example"
        }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name = "ecs-service"
  # Attach IAM role only if you use ELB otherwise resource will not be created.
  iam_role = aws_iam_role.ecs_service_role.name
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.esc_test_task.arn
  desired_count = var.desired_task_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent = var.deployment_maximum_percent
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-target-group-lb.arn
    container_name = "nginx"
    container_port = 80
  }
}

