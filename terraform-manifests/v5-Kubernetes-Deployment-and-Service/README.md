## Configure kubeconfig for kubectl
```t
# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name isi-dev-eks-eval-project

# List Worker Nodes
kubectl get nodes
kubectl get nodes -o wide

# Verify Services
kubectl get svc
```

## Review Sample Application - Deployment Manifest
- **File:** `kube-manifests/01-Deployment.yaml`

## Review Sample Application - Node Port Service Manifest
- **File:** `kube-manifests/03-NodePort-Service.yaml`
## Review Sample Application - AWS Network Load Balancer Service Manifest
- **File:** `kube-manifests/04-NLB-LoadBalancer-Service.yaml`

## Deploy Sample Application in EKS k8s Cluster and Verify
```t
# Deploy Sample Application
kubectl apply -f kube-manifests/

# List Pods
kubectl get pods -o wide
Observation: 
1. Two app pods in Public Node Groups should be displayed

# List Services
kubectl get svc

## Verify Load Balancer
1. Go to Services -> EC2 -> Load Balancing -> Load Balancers
2. Verify Classic Load Balancer -> Verify Tabs
   - Description: Make a note of LB DNS Name
   - Instances: Status of Instances should be in state "InService"
   - Health Checks
   - Listeners
   - Monitoring
4. Verify Network Load Balancer -> Verify Tabs
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
# Undeploy Application
kubectl delete -f kube-manifests/
```



