#--- 2_compute/config.tf ---

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 2.61.0"
  }
  backend "s3" {
    key = "2_compute"
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}

# access remote state of tf_networking
data "terraform_remote_state" "1_network" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key = "1_network"
    region = var.region
  }
}