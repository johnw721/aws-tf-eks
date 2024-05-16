
# VPC

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

# EC2 instance

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type               = var.instance_type
  key_name                    = "tf-jk-aws-instance"
  monitoring                  = true
  vpc_security_group_ids      = [module.security-group.this_security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
# Using script to install jenkins on EC2 instance
  user_data = file("jenkins-installation.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}