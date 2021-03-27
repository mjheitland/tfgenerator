#--- 1_network/variables.tf ---

variable region {
  description = "AWS region we are deploying to"
  type        = string
}

variable basic_tags {
  description = "A set of basic tags for all AWS resources."
  type        = map(string)
}