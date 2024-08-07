
# Create VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true


  tags = {
    Terraform   = "true"
    name        = "aws-terraform-jenkins-eks example"
    Environment = "dev"
  }
}

# Private Subnet

# module "private_subnets" {
#   source  = "claranet/vpc-modules/aws//modules/private-subnets"
#   version = "0.4.0"

#   count                   = 2
#   vpc_id                  = module.vpc.default_vpc_id
#   cidr_block              = var.private_subnets[0]
#   subnet_count            = 3
#   availability_zones      = data.aws_availability_zones.azs

# }

# # Public Subnet

# module "public_subnets" {
#   source  = "claranet/vpc-modules/aws//modules/public-subnets"
#   version = "0.4.0"

#   vpc_id                  = module.vpc.default_vpc_id
#   gateway_id              = module.vpc.igw_id
#   map_public_ip_on_launch = true
#   cidr_block              = var.public_subnets[0]
#   subnet_count            = 3
#   availability_zones      = data.aws_availability_zones.azs
#   tags = {

#   }
# }


# Monitoring Solutions


## Create IAM Role named Example


## Install Splunk on a relevant components


## Set up CloudWatch Dashboard to watch 


## Make sure everything has a tag for resource tracking

# Create an EKS cluster in the private subnet

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.default_vpc_id
  subnet_ids = module.vpc.public_subnets

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



#Create EBS Volumes 
# resource "aws_ebs_volume" "ebs_v1" {
#   availability_zone = "us-east-1a"
#   size              = 10
#   type              = "gp3"
#   encrypted         = true
#   kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
#   count             = 2
#   tags = {
#     Name = "ebs_v1"
#   }

# }

# IAM Policy Attachment 

# resource "aws_iam_policy" "policy_EBS_Volume_Attachment" {
#   name        = "test_policy"
#   path        = "/"
#   description = "My test policy"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     "Version" : "2024-06-12",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:AttachVolume",
#           "ec2:CreateSnapshot",
#           "ec2:CreateTags",
#           "ec2:CreateVolume",
#           "ec2:DeleteSnapshot",
#           "ec2:DeleteTags",
#           "ec2:DeleteVolume",
#           "ec2:DescribeInstances",
#           "ec2:DescribeSnapshots",
#           "ec2:DescribeTags",
#           "ec2:DescribeVolumes",
#           "ec2:DetachVolume"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }

#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

# resource "aws_iam_role" "eks_worknode" {
#   name = "${var.cluster_name}-worknode"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "worknode-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_worknode.name
# }

# resource "aws_iam_role_policy_attachment" "worknode-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_worknode.name
# }

# resource "aws_iam_role_policy_attachment" "worknode-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_worknode.name
# }

# resource "aws_eks_node_group" "eks-worknode-group" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${var.cluster_name}-worknode-group"
#   node_role_arn   = aws_iam_role.eks_worknode.arn
#   subnet_ids      = aws_subnet.eks_vpc_public_subnet[*].id
#   remote_access {
#     ec2_ssh_key = var.ssh_key_name
#   }

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.worknode-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.worknode-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.worknode-AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# resource "aws_iam_role_policy_attachment" "worknode-AmazonEBSCSIDriver" {
#   policy_arn = aws_iam_policy.policy_EBS_Volume_Attachment.arn
#   role       = aws_iam_role.eks_worknode.name
# }

# Attach EBS Volume to EKS Cluster
#
#resource "aws_volume_attachment" "ebs_v_attachment" {
# count       = 2
# device_name = "/dev/sdh"
#volume_id   = aws_ebs_volume.ebs_v1.id
#instance_id = module.eks.cluster_arn
#}


# Create DB with read replicas in the private subnet
module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

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



  vpc_id = module.vpc.vpc_id
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

# Create separate environment for end to end testing

## Create Private subnet

## Create separate route table and associate

## Security Groups 

## Create testcases to be ran in Selenium Java

## Open website, test it, send report to email


# Create AWS FIS module to test prod environment in real time


# Create Splunk Integration

resource "aws_iam_role" "example" {
  name        = "example"
  description = "Example IAM role"
  assume_role_policy = jsonencode({
    Version = "2024-06-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "logs.amazonaws.com",         # Added for CloudWatch Logs
            "vpc-flow-logs.amazonaws.com" # Added for VPC Flow Logs
          ]
        }
      }
    ]
  })
}

## Attach policies for CloudWatch Logs and VPC Flow Logs permissions
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2024-06-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

## Create CloudWatch Log Group named Example
data "aws_cloudwatch_log_group" "example" {
  name = "aws-tf-eks"
}

## Create VPC Flow Log
resource "aws_flow_log" "flow_log_for_splunk" {
  iam_role_arn    = aws_iam_role.example.arn
  log_destination = data.aws_cloudwatch_log_group.example.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}