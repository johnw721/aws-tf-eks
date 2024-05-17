terraform {
  required_providers {
    aws = {
      # the source of where to pull the credentials from.  This is usually AWS, but can be other providers like Azure or GCP as
      source = "hashicorp/aws",
      # the required version to be used
      version = "5.47.0"
    }
  }

}


provider "aws" {
  region = "us-east-1"
}