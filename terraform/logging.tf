# We'll need it in the ECS to allow it to log into CloudWatch
# If logging to CloudWatch is not configured correctly ECS will work it will be just hell of a lot of much more difficult
# to find what caused problems.
resource "aws_cloudwatch_log_group" "ecs_log" {
  name = "/ecs/test-cluster"
}