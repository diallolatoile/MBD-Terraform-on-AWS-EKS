# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../../v4-01-ekscluster-terraform-manifests/terraform.tfstate"
   }
}

