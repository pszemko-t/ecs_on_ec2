#Task execution role is a role that that can be assumed by ECS container agent
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "ecs-taskexec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-policy.json
}

data "aws_iam_policy_document" "ecs-task-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-taskexec" {
  role = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#This role is used by task to allow the container to be able to access AWS resources
resource "aws_iam_role" "ecs-task" {
  name = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-policy.json
}