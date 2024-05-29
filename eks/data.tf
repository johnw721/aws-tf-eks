data "aws_ami" "jenkins_ami" {
  most_recent = true
  owners      = ["amazon"]

# Filter the data down to machines with this specific ami

  filter {
    name   = "aws_ami"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240412.0-x86_64-gp3"]
  }

# How durable do you want the storage to be
  filter {
    name   = "root-device-type"
    values = ["ebs"] # Data persist through reboots
  }

# How do you want this machine to be virtualized
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Note that Windows requires HVM, 
# so ARI/AKI are not applicable to Windows instances at all because
# (HVM) instances do not use ARI or AKIs at all. 
#All of the boot sequence is part of the AMI itself. This includes both EBS and instance-store backed instance types.
# Further Info: https://zhihuicao.wordpress.com/2015/06/13/para-virtualization-full-virtualization-differences/


data "aws_availability_zones" "azs" {

}