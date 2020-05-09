# Terraform Generator

Input: Terraform templates and YAML file describing the infrastructure
Output: Terraform code to set up infrastructure

terraform init --backend-config=../backend_configs/dev_eu-west-1.conf
terraform apply -var-file=env-vars/dev_eu-west-1.tfvars
