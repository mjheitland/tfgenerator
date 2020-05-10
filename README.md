# Terraform Generator

Generates automatically Terraform code to set up infrastructure in AWS Cloud

## How to generate Terraform code
Input:   "infrastructure.yml" and Terraform templates
Output:  Terraform code to set up infrastructure
Command: python3 tfgenerator.py

## Layer 0 - setting up remote state
* comment out backend block (./out/0_tfstate/config.tf line 8 - 10, use # for comments)
* terraform init -backend-config=../backend_configs/dev_eu-west-1.conf
* terraform apply -var-file=env_vars/dev_eu-west-1.tfvars -auto-approve
* remove comments from backend block (./out/0_tfstate/config.tf line 8 - 10)
* terraform init -backend-config=../backend_configs/dev_eu-west-1.conf -force-copy
* terraform apply -var-file=env_vars/dev_eu-west-1.tfvars -auto-approve
* rm terraform.tfstate*

## Setting up Layer 1, 2 etc.
* cd <layer>
* terraform init -backend-config=../backend_configs/dev_eu-west-1.conf
* terraform apply -var-file=env_vars/dev_eu-west-1.tfvars

## Destroy layers in reverse setup order
terraform destroy -var-file=env_vars/dev_eu-west-1.tfvars -auto-approve
