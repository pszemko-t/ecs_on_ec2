variable "ecs_cluster" {
  default = "test_cluster"
}

variable "instance_type" {
  default = "t2.small"
}

variable "max_instances" {
  default = 2
}

variable "min_instances" {
  default = 2
}

variable "desired_task_count" {
  default = 2
}

# So it will be possible that half of Your tasks must be running during deployment to service
variable "deployment_minimum_healthy_percent" {
  default = 50
}

variable "deployment_maximum_percent" {
  default = 100
}

# Will be used for subnets creation. So we will know where to put them.
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "identity" {}

# Not sure if it's always a better idea to use data source instead of explicitly stating id...
# But for the sake of learning its good to know that it could be done that way :)
# Remember that filters I used kind of make sense only if used for certain instance types.
# For other EC2 types filters might "technically" work but instance itself will not be created since AMI might be invalid for that type.
data "aws_ami" "ecs-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm*"]
  }
# To be honest that one is rather redundant since it is defined in the name of AMI.
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

# Thanks to output after cluster apply we will know the address of the ECS cluster (to load it from the internet)
output "address" {
  value = aws_lb.ecs-load-balancer.dns_name
}