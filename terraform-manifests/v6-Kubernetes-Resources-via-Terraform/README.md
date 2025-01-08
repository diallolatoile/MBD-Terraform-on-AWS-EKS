## Create Kubernetes Resources: Execute Terraform Commands
```t
# Change Directroy
cd v6-Kubernetes-Resources-via-Terraform/v4-02-k8sresources-terraform-manifests

# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
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
rm -rf .terraform* terraform.tfstate*

# Delete EKS Cluster
cd terraform-manifests/v4-01-ekscluster-terraform-manifests/
terraform apply -destroy -auto-approve
rm -rf .terraform* terraform.tfstate*
```