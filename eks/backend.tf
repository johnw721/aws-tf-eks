
# Recommmended to not use variables in this block
terraform {
  backend "s3" {

    # This is the default backend for the Project
    bucket = "grey.terraform.aws.jenkins.pipeline"

    # Where to store the pipeline configuration data in S3
    key = "jenkins/terraform.tfstate"

    # AWS region where everything will be deployed
    region = "us-east-1"
  }

}