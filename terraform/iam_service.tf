#Third step is to handle IAM
# Do bear in mind that roles attached to services are needed only when using Load Balancer in front of the EC2 instances
# If there is no LB used (that Use Case is described in the article) there is no need to create any of those.
# If you will create those resources you will not be able to attach them to service...

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs-service-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-service-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-att" {
  role = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs.amazonaws.com"]
      type = "Service"
    }
  }
}