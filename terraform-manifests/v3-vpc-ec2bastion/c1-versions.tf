# Terraform Block
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default" #bobo.isidkr profile
}
/*
Note-1:  AWS Credentials Profile (profile = "default") configured on my local desktop terminal
.aws/credentials
*/