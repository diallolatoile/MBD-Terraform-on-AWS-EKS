# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"
    
  # VPC Basic Details
  name = "vpc-eks-eval-project"
  cidr = "10.0.0.0/16"   
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]

  # Database Subnets
  create_database_subnet_group = true
  create_database_subnet_route_table= true
  database_subnets    = ["10.0.151.0/24", "10.0.152.0/24"]

  #create_database_nat_gateway_route = true
  #create_database_internet_gateway_route = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = true
  single_nat_gateway = true

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  tags = {
    Owner = "bobo.isidkr"
    Environment = "dev-eks-eval-project"
  }

  vpc_tags = {
    Name = "vpc-eks-eval-project"
  }
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}



