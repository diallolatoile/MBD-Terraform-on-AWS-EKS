# Create a Null Resource and Provisioners
resource "null_resource" "copy_ec2_keys" {
  depends_on = [module.ec2_public]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip    
    user     = "ec2-user"
    password = ""
    private_key = file("private-key/eks-terraform-key.pem")
  }

## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "private-key/eks-terraform-key.pem"
    destination = "/home/ec2-user/eks-terraform-key.pem"
  }
## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ec2-user/eks-terraform-key.pem /tmp/eks-terraform-key.pem",
      "sudo chmod 400 /tmp/eks-terraform-key.pem"
    ]
  }
## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command = "echo VPC created on %DATE% and VPC ID: ${module.vpc.vpc_id} >> C:/Files/ISI-Dakar/Cloud_Services_M1_G2_S1/AWS_Terraform_EKS_K8s/Practices/Correction/terraform-manifests/v3-vpc-ec2bastion/local-exec-output-files/creation-time-vpc-id.txt"
    working_dir = "C:/Files/ISI-Dakar/Cloud_Services_M1_G2_S1/AWS_Terraform_EKS_K8s/Practices/Correction/terraform-manifests/v3-vpc-ec2bastion/local-exec-output-files/"
    #on_failure = continue
  }

}