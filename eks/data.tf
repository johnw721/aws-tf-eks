
# AMI stands for Amazon Machine Image. It's the template the
# machine is created from
data "aws_ami" "jenkins_ami" {
  most_recent = true
  owners      = ["amazon"]

  # Filter the data down to machines with this specific ami
  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.20240805.0-kernel-6.1-x86_64"]
  }

  # How durable do you want the storage to be
  filter {
    name   = "root-device-type"
    values = ["ebs"] # Data persist through reboots
  }

  # How do you want this machine to be virtualized
  filter {
    name   = "virtualization-type"
    values = ["hvm"] // [image-comments/Paravirtualization Visualized.png]
  }
}

# Note that Windows requires HVM, 
# so ARI/AKI are not applicable to Windows instances at all because
# (HVM) instances do not use ARI or AKIs at all. 
# All of the boot sequence is part of the AMI itself. This includes both EBS and instance-store backed instance types.
# Further Info: 
# - https://cloudacademy.com/blog/aws-ami-hvm-vs-pv-paravirtual-amazon/
# - https://mohitdtumce.medium.com/understanding-full-virtualization-paravirtualization-and-hardware-assist-730d3c9aa04c
# - https://zhihuicao.wordpress.com/2015/06/13/para-virtualization-full-virtualization-differences/


data "aws_availability_zones" "azs" {

}