# infra-cloud
## Required tools
### CIVO cloud account 
https://www.civo.com/

#### CIVO token
https://dashboard.civo.com/security
> It will be used later to provision the k8s cluster using the Terraform

### Cloudflare account
https://dash.cloudflare.com/sign-up

### Terraform
```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## Running
```
terraform init
terraform plan
terraform apply
```

### Variables
Alternatively create a file named terraform.tfvars with the following content:
```
civo_token = <your_civo_token>
cloudflare_email = <your_cloudFlare_email>
cloudflare_api_global_key = <your_cloudFlare_api_globalKey>
```