# Terraform Block
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks-eval-project"
    key    = "dev/eks-eval-project-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "dev-eks-eval-project-cluster"  
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