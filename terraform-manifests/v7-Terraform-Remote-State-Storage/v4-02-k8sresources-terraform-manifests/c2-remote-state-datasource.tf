# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-on-aws-eks-eval-project"
    key    = "dev/eks-eval-project-cluster/terraform.tfstate"
    region = "us-east-1" 
  }
}
