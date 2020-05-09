#--- 1_network/variables.tf

variable account {
  description = "AWS account"
  type        = string
}

variable region {
  description = "AWS region we are deploying to"
  type        = string
}
