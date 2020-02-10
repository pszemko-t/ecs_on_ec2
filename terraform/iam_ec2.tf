# Used for EC2 instances
# Creates a role that will be attached to instances
resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

# We don't need to create policy since there is already an AWS managed policy that fits perfectly.
# We only need to attach it to a role that was created
resource "aws_iam_role_policy_attachment" "ecs-instance-role-att" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role = aws_iam_role.ecs-instance-role.name
}

# Need instance profile to be able to attach a role to instances.
resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}