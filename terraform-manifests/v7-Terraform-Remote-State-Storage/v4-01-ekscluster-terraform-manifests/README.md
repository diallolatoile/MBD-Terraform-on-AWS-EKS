# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name isi-dev-eks-eval-project

# List Worker Nodes
kubectl get nodes
kubectl get nodes -o wide

# Verify Services
kubectl get svc

Connect to EKS Worker Nodes using Bastion Host

# Connect to Bastion EC2 Instance
ssh -i private-key/eks-terraform-key.pem ec2-user@<Bastion-EC2-Instance-Public-IP>
cd /tmp

# Connect to Kubernetes Worker Nodes - Public Node Group
ssh -i private-key/eks-terraform-key.pem ec2-user@<Public-NodeGroup-EC2Instance-PublicIP> 
[or]
ec2-user@<Public-NodeGroup-EC2Instance-PrivateIP>

# Connect to Kubernetes Worker Nodes - Private Node Group from Bastion Host
ssh -i eks-terraform-key.pem ec2-user@<Private-NodeGroup-EC2Instance-PrivateIP>

##### BOTH PUBLIC AND PRIVATE NODE GROUPS ####
# Verify if kubelet and kube-proxy running
ps -ef | grep kube

# Verify kubelet-config.json
cat /etc/kubernetes/kubelet/kubelet-config.json

# Verify kubelet kubeconfig
cat /var/lib/kubelet/kubeconfig

# Verify clusters.cluster.server value(EKS Cluster API Server Endpoint)  DNS resolution which is taken from kubeconfig
nslookup <EKS Cluster API Server Endpoint>
nslookup ...................................
Very Important Note: Test this on Bastion Host, as EKS worker nodes doesnt have nslookup tool installed. 
[or]
# Verify clusters.cluster.server value(EKS Cluster API Server Endpoint)   with wget 
Try with wget on Node Group EC2 Instances (both public and private)
wget <Kubernetes API Server Endpoint>
wget ....................................

ps -ef | grep kube

--pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1


Verify Namespaces and Resources in Namespaces

# Verify Namespaces
kubectl get namespaces
kubectl get ns 
Observation: 4 namespaces will be listed by default
1. default
2. kube-node-lease
3. kube-public
4. kube-system

# Verify Resources in kube-node-lease namespace
kubectl get all -n kube-node-lease

# Verify Resources in kube-public namespace
kubectl get all -n kube-public

# Verify Resources in default namespace
kubectl get all -n default
Observation: 
1. Kubernetes Service: Cluster IP Service for Kubernetes Endpoint

# Verify Resources in kube-system namespace
kubectl get all -n kube-system
Observation: 
1. Kubernetes Deployment: coredns, ebs-csi-controller
2. Kubernetes DaemonSet: aws-node, kube-proxy, ebs-csi-node-windows, ebs-csi-node, eks-pod-identity-agent
3. Kubernetes Service: kube-dns, eks-extension-metrics-api
4. Kubernetes Pods: coredns, aws-node, kube-proxy, ebs-csi-node, ebs-csi-controller, eks-pod-identity-agent

## Step-17: Verify pods in kube-system namespace

# Verify System pods in kube-system namespace
kubectl get pods # Nothing in default namespace
kubectl get pods -n kube-system
kubectl get pods -n kube-system -o wide

# Verify Daemon Sets in kube-system namespace
kubectl get ds -n kube-system
Observation: The below two daemonsets will be running
1. aws-node
2. kube-proxy
3. ebs-csi-node-windows, 
4. ebs-csi-node, 
5. eks-pod-identity-agent

# Describe aws-node Daemon Set
kubectl describe ds aws-node -n kube-system
Observation: 
1. Reference "Image" value it will be the ECR Registry URL 

# Describe kube-proxy Daemon Set
kubectl describe ds kube-proxy -n kube-system
1. Reference "Image" value it will be the ECR Registry URL 

# Describe coredns Deployment
kubectl describe deploy coredns -n kube-system

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify Kubernetes Worker Nodes
kubectl get nodes -o wide
Observation:
1. Should see EKS Worker Node running

# Stop EC2 Instance (Bastion Host)
Services -> EC2 -> Instances -> isi-dev-BastionHost -> Instance State -> Stop

