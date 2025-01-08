@echo on 
Set key=terraform-manifests\v3-vpc-ec2bastion\private-key\eks-terraform-key.pem
pause
icacls.exe %key% /reset
pause
icacls.exe %key% /inheritance:r
pause
icacls.exe %key% /GRANT pcmbo:r
pause