variable "vpc_cidr" {
  type        = string
  description = "CIDR Block for the VPC"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}