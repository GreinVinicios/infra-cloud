# GCP

> Before start you will need a GCP account

```
gcloud auth login
gcloud auth application-default login
gcloud auth application-default set-quota-project <you_project_id>

config set project <your_project_id>
```

Create one bucket at Cloud Storage menu on Google Console
Change the name on the providers.tf file to the choosen name

Create one file named terraform.tfvars
```
project = "<your_project_id>"
region = "us-west1"
location = "us-west1-a"
```

Run the following Terraform commands:
```
terraform init
terraform plan
terraform apply
```