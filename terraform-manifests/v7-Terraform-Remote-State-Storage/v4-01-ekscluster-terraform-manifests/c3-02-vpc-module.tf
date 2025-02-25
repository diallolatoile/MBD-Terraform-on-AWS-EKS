# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {  
  #state = "available"
  #exclude_names = ["us-east-1xxx", "us-east-1xxx"]
}


# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"    

  # VPC Basic Details
  name = local.eks_cluster_name
  cidr = var.vpc_cidr_block
  #azs             = var.vpc_availability_zones
  azs             = data.aws_availability_zones.available.names
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
    Name = "public-subnet-${local.eks_cluster_name}"
    "kubernetes.io/role/elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"        
  }
  private_subnet_tags = {
    Type = "private-subnets"
    Name = "private-subnet-${local.eks_cluster_name}"
    "kubernetes.io/role/internal-elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"    
  }

  database_subnet_tags = {
    Type = "database-subnets"
    Name = "private-db-subnet-${local.eks_cluster_name}"
  }

  igw_tags = {
    Name = "igw-${local.eks_cluster_name}"
  }

  nat_gateway_tags = {
    Name = "nat-gw-${local.eks_cluster_name}"
  }

  private_route_table_tags = {
    Name = "private-route-table-${local.eks_cluster_name}"
  }

  public_route_table_tags = {
    Name = "public-route-table-${local.eks_cluster_name}"
  }

  database_route_table_tags = {
    Name = "db-route-table-${local.eks_cluster_name}"
  }
  
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}