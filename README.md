# Setting up Bastion Host both azure way and self way

## Azure_bastion
This is creating Azure bastion host using terraform
1. Create subnet for both VM and Bastion, bastion address prefix should be above /26
2. Create azurerm bastion host 
3. Create network security for vm, associate NSG to vm
4. Create linux vm


## Self made bastion(Jump server)
1. Create 2 vms, jump server with public ip, vm without
2. Create network security for vm to only allow jump server to ssh
3. Create network security for jump server to allow ssh from specific source address

Tips
- Could implement MFA like google authenticator
- Disable root login
- Add fail2ban to prevent brute force attacks
- Restrict jump server to only allow trusted IP
