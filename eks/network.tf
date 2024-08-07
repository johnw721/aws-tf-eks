
# Elastic IP Address

resource "aws_eip" "eip_for_nat_gateway" {
  domain = "vpc"
}

resource "aws_eip" "secondary" {
  domain = "vpc"
}

# NAT Gateway in Public Subnet
# Further info:
# - https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html

resource "aws_nat_gateway" "example" {
  allocation_id                  = aws_eip.eip_for_nat_gateway.id # Assign a Elastic IP Address
  subnet_id                      = module.vpc.public_subnets[0]
  secondary_allocation_ids       = [aws_eip.secondary.id]
  secondary_private_ip_addresses = ["10.0.1.5"]
}

# Security Group

module "security-group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for jenkins server"
  vpc_id      = module.vpc.default_vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    name = "jenkins-instance-sg"
  }
}

# Create internal load balancer

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "example" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = module.cluster.cluster_id
  port             = 80
}

# Route Table
resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "private-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
}

# Route Table Association

resource "aws_route_table_association" "private" {
  subnet_id      = module.vpc.private_subnets[0]
  route_table_id = aws_route_table.private.id
  count          = 1

}