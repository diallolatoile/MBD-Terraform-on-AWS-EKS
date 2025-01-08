# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"    

  # VPC Basic Details
  name = "${local.name}-${var.vpc_name}"
  cidr = var.vpc_cidr_block
  azs             = var.vpc_availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets  

  # Database Subnets
  database_subnets = var.vpc_database_subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway 
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
    Name = "public-subnet-eks-eval-project"
  }
  private_subnet_tags = {
    Type = "Private Subnets"
    Name = "private-subnet-eks-eval-project"
  }  
  database_subnet_tags = {
    Type = "Private Database Subnets"
    Name = "private-db-subnet-eks-eval-project"
  }

  igw_tags = {
    Name = "igw-eks-eval-project"
  }

  nat_gateway_tags = {
    Name = "nat-gw-eks-eval-project"
  }

  private_route_table_tags = {
    Name = "private-route-table-eks-eval-project"
  }

  public_route_table_tags = {
    Name = "public-route-table-eks-eval-project"
  }

  database_route_table_tags = {
    Name = "db-route-table-eks-eval-project"
  }
  
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}