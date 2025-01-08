## Create S3 Bucket
- Go to Services -> S3 -> Create Bucket
- **Bucket name:** terraform-on-aws-eks-eval-project
- **Region:** US-East (N.Virginia)
- **Bucket settings for Block Public Access:** leave to defaults
- **Bucket Versioning:** Enable
- Rest all leave to **defaults**
- Click on **Create Bucket**
- **Create Folder**
  - **Folder Name:** dev
  - Click on **Create Folder**
- **Create Folder**
  - **Folder Name:** dev/eks-eval-project-cluster
  - Click on **Create Folder**  
- **Create Folder**
  - **Folder Name:** dev/app1k8s
  - Click on **Create Folder**    


## EKS Cluster: Terraform Backend Configuration
```t
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks-eval-project"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "dev-eks-eval-project-cluster"    
  }  
```

## terraform.tfvars
- Update `environment` to `dev`
```t
# Generic Variables
aws_region = "us-east-1"
environment = "dev"
business_divsion = "isi"
```

### EKS Cluster DynamoDB Table
- Create Dynamo DB Table for EKS Cluster
  - **Table Name:** dev-eks-eval-project-cluster
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create**
### App1 Kubernetes DynamoDB Table
- Create Dynamo DB Table for app1k8s
  - **Table Name:** dev-app1k8s
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create**


## Create EKS Cluster: Execute Terraform Commands
```t
# Change Directory
cd v4-01-ekscluster-terraform-manifests

# Initialize Terraform 
terraform init
Observation: 
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

# Terraform Validate
terraform validate

# Review the terraform plan
terraform plan 
Observation: 
1) Below messages displayed at start and end of command
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
2) Verify DynamoDB Table -> Items tab

# Create Resources 
terraform apply -auto-approve

# Verify S3 Bucket for terraform.tfstate file
dev/eks-cluster/terraform.tfstate
Observation: 
1. Finally at this point you should see the terraform.tfstate file in s3 bucket
2. As S3 bucket version is enabled, new versions of `terraform.tfstate` file new versions will be created and tracked if any changes happens to infrastructure using Terraform Configuration Files
```

## Kubernetes Resources: Terraform Backend Configuration
- **File Location:** `v4-02-k8sresources-terraform-manifests/c1-versions.tf`
- Add the below listed Terraform backend block in `Terrafrom Settings` block in `c1-versions.tf`
```t
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks-eval-project"
    key    = "dev/app1k8s/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-app1k8s"    
  }   
```
## c2-remote-state-datasource.tf
- **File Location:** `v4-02-k8sresources-terraform-manifests/c2-remote-state-datasource.tf`
- Update the EKS Cluster Remote State Datasource information
```t
# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-on-aws-eks-eval-project-cluster"
    key    = "dev/eks-eval-project-cluster/terraform.tfstate"
    region = "us-east-1" 
  }
}
```


## Create Kubernetes Resources: Execute Terraform Commands
```t
# Change Directory
cd v4-02-k8sresources-terraform-manifests

# Initialize Terraform 
terraform init
Observation: 
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

# Terraform Validate
terraform validate

# Review the terraform plan
terraform plan 
Observation: 
1) Below messages displayed at start and end of command
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
2) Verify DynamoDB Table -> Items tab

# Create Resources 
terraform apply -auto-approve

# Verify S3 Bucket for terraform.tfstate file
dev/app1k8s/terraform.tfstate
Observation: 
1. Finally at this point you should see the terraform.tfstate file in s3 bucket
2. As S3 bucket version is enabled, new versions of `terraform.tfstate` file new versions will be created and tracked if any changes happens to infrastructure using Terraform Configuration Files
```

## Configure kubeconfig for kubectl
```t
# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name isi-dev-eks-eval-project

# List Worker Nodes
kubectl get nodes
kubectl get nodes -o wide
Observation:
1. Verify the External IP for the node

# Verify Services
kubectl get svc
```


## Verify Kubernetes Resources
```t
# List Nodes
kubectl get nodes -o wide

# List Pods
kubectl get pods -o wide
Observation: 
1. Both app pod should be in Public Node Group 

# List Services
kubectl get svc
kubectl get svc -o wide
Observation:
1. We should see both Load Balancer Service and NodePort service created


# Access Sample Application on Browser
http://<NLB-DNS-NAME>
http://-----------------------------.us-east-1.elb.amazonaws.com
```

## Verify Kubernetes Resources via AWS Management console
1. Go to Services -> EC2 -> Load Balancing -> Load Balancers
2. Verify Tabs
   - Description: Make a note of LB DNS Name
   - Instances
   - Health Checks
   - Listeners
   - Monitoring
Verify Network Load Balancer -> Verify Tabs
   - Description: Make a note of LB DNS Name
   - Listeners
   - WAIT FOR NLB TO BE IN ACTIVE STATE. IT WILL TAKE SOMETIME TO BE ACTIVE.   
```t
# List Services
kubectl get svc

# Access Sample Application on Browser

http://<NLB-LB-DNS-NAME>
http://-------------------------------------------.elb.us-east-1.amazonaws.com
```   

## Node Port Service Port - Update Node Security Group
- **Important Note:** This is not a recommended option to update the Node Security group to open ports to internet, but just for learning and testing we are doing this. 
- Go to Services -> Instances -> Find Public Node Group Instance -> Click on Security Tab
- Find the Security Group with name `eks-remoteAccess-`
- Go to the Security Group (Example Name: sg------------------ - eks-remoteAccess------------------)
- Add an additional Inbound Rule
   - **Type:** Custom TCP
   - **Protocol:** TCP
   - **Port range:** 31280
   - **Source:** Anywhere (0.0.0.0/0)
   - **Description:** NodePort Rule
- Click on **Save rules**

## Verify by accessing the Sample Application using NodePort Service
```t
# List Nodes
kubectl get nodes -o wide
Observation: Make a note of the Node External IP

# List Services
kubectl get svc
Observation: Make a note of the NodePort service port "myapp1-nodeport-service" which looks as "80:31280/TCP"

# Access the Sample Application in Browser
http://<EXTERNAL-IP-OF-NODE>:<NODE-PORT>
http://-----------------:31280
```

## Remove Inbound Rule added 
- Go to Services -> Instances -> Find Private Node Group Instance -> Click on Security Tab
- Find the Security Group with name `eks-remoteAccess-`
- Go to the Security Group (Example Name: sg------------------ - eks-remoteAccess------------------))
- Remove the NodePort Rule which we added.

## Clean-Up
```t
# Delete Kubernetes  Resources
cd v4-02-k8sresources-terraform-manifests
terraform apply -destroy -auto-approve
del /q .terraform*
del /q terraform.tfstate*
rmdir /s /q .terraform

# Verify Kubernetes Resources
kubectl get pods
kubectl get svc

# Delete EKS Cluster (Optional)

cd v4-01-ekscluster-terraform-manifests/
terraform apply -destroy -auto-approve
del /q .terraform*
del /q terraform.tfstate*
rmdir /s /q .terraform
```