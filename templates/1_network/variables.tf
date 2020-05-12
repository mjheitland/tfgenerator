#--- 1_network/variables.tf ---

variable project {
  description = "Project name is used as namespace for Terraform remote state and other resources."
  type        = string
}

variable account {
  description = "AWS account"
  type        = string
}

variable region {
  description = "AWS region we are deploying to"
  type        = string
}

variable basic_tags {
  description = "A set of basic tags for all AWS resources."
  type        = map(string)
}