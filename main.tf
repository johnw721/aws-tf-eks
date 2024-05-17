
# Create VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = module.private_subnets.outputs.private_subnets
  public_subnets  = module.public_subnets.outputs.public_subnets

  enable_dns_hostnames = true


  tags = {
    Terraform   = "true"
    name        = "aws-terraform-jenkins-eks example"
    Environment = "dev"
  }
}

# Private Subnet

module "private_subnets" {
  source = "claranet/vpc-modules/aws//modules/private-subnets"
  version = "0.4.0"

  vpc_id                  = module.vpc.vpc_id
  gateway_id              = module.vpc.internet_gateway_id
  map_public_ip_on_launch = true
  cidr_block              = var.private_subnets[0]
  subnet_count            = 3
  availability_zones      = data.aws_availability_zones.azs

}

# Public Subnet

module "public_subnets" {
  source = "claranet/vpc-modules/aws//modules/public-subnets"
  version = "0.4.0"

  vpc_id                  = module.vpc.vpc_id
  gateway_id              = module.vpc.internet_gateway_id
  map_public_ip_on_launch = true
  cidr_block              = var.public_subnets[0]
  subnet_count            = 3
  availability_zones      = data.aws_availability_zones.azs
}

# NAT Gateway in Public Subnet

resource "aws_nat_gateway" "example" {
  allocation_id                  = aws_eip.example.id
  subnet_id                      = aws_subnet.example.id
  secondary_allocation_ids       = [aws_eip.secondary.id]
  secondary_private_ip_addresses = ["10.0.1.5"]
}

# Security Group

module "security-group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for jenkins server"
  vpc_id      = module.vpc.vpc_default_vpc_id

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

# Subnets

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[0]

  tags = {
    Name = "Main"
  }
}




 # Create an EKS cluster in the private subnet

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = ["t2.small"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

        # Attach EBS Volumes 

    # Create DB with read replicas in the private subnet
module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "test-aurora-db-postgres96"
  engine         = "aurora-postgresql"
  engine_version = "14.5"
  instance_class = "db.r6g.large"
  instances = {
    one = {}
    2 = {
      instance_class = "db.r6g.2xlarge"
    }
  }

autoscaling_enabled = true

autoscaling_max_capacity = 3

autoscaling_min_capacity = 2

autoscaling_scale_in_cooldown = 300

autoscaling_scale_out_cooldown = 400




  vpc_id               = "vpc-12345678"
  db_subnet_group_name = "db-subnet-group"
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = ["10.20.0.0/20"]
    }
    ex1_ingress = {
      source_security_group_id = "sg-12345678"
    }
  }

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

    # Create Internal Load Balancer

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.private : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Create separate environment for testing

# 
