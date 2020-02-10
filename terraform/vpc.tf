#Second step is to create VPC where EC2 will be placed

#VPC resource. Since it's free we'll create a new network environment for our cluster.
resource "aws_vpc" "ecs_test" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "ecs_test"
        env = "dev"
    }
}

resource "aws_subnet" "ecs_subnets" {
# Since we want 3...
    count =3
    vpc_id = aws_vpc.ecs_test.id
# That one is, in fact, interesting it will allow us to create 3 subnets with different CIDRs details in the article.
    cidr_block = replace(aws_vpc.ecs_test.cidr_block, "0.0/16", format("%d.0/24", count.index))
# One subnet per AZ :)
    availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
    tags = {
        Name = "ecs_test_subnet_${count.index}"
        env = "dev"
    }
}

# To make it available from the Internet (if needed)
resource "aws_internet_gateway" "ecs_ig" {
  vpc_id = aws_vpc.ecs_test.id
  tags = {
      Name = "ecs_test_ig"
  }
}

# So the internet-bound traffic could be routed to IGW
resource "aws_route_table" "ecs_route" {
  vpc_id = aws_vpc.ecs_test.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.ecs_ig.id
  }
  tags = {
      Name = "ecs_test"
  }
}

# Associates subnets to our IGW.
resource "aws_route_table_association" "ecs_test"{
    count = 3
    subnet_id = aws_subnet.ecs_subnets[count.index].id
    route_table_id = aws_route_table.ecs_route.id
}

# Security groups needed to explicitly state what traffic can flow into and from our network
resource "aws_security_group" "ecs_test_sg" {
    name = "ecs_sg"
    vpc_id = aws_vpc.ecs_test.id

  #needed to ssh into instance
   ingress {
       from_port = 22
       to_port = 22
       protocol = "tcp"
# Do bear in mind that sometimes it might be beneficial to use appropriate CIDR block to pinpoint who can SSH int
# the instance and not just ... any IP.
       cidr_blocks = ["0.0.0.0/0"]
   }

  # Allow incomming traffic on port 80
   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

  #Allow incomming traffic on port 443
   ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
    }


    # Allowing outbound traffic from subnets in our VPC to the outside world
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"]
    }
    tags = {
       Name = "ecs_test_sg"
     }
}
