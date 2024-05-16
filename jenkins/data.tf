data "aws_ami" "jenkins_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "aws_ami"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240412.0-x86_64-gp3"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_availability_zones" "azs" {

}