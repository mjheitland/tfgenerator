#--- config.tf ---

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 2.50.0"
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}
