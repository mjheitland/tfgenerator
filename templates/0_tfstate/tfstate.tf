#--- 0_tfstate/tfstate.tf

#-------------
#--- Variables
#-------------

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

variable bucket {
  description = "Name of S3 bucket to store Terraform's remote state"
  type        = string
}

variable table {
  description = "Name of DynamoDB table to lock Terraform's deployments"
  type        = string
}


#-------------
#--- Resources
#-------------

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.bucket

  # prevent accidental deletion of this bucket
  # (if you really have to destroy this bucket, change this value to false and reapply, then run destroy)
  lifecycle {
    prevent_destroy = false
  }

  # enable versioning so we can see the full revision history of our state file
  versioning {
    enabled = true
  }

  # enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tfstate_table" {
  name = var.table
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


#----------
#--- Output
#----------

output "output_s3_bucket_arn" {
  value       = aws_s3_bucket.tfstate_bucket.arn
  description = "The arn of the s3 bucket that stores terraform's remote state"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.tfstate_table.arn
  description = "The arn of the dynamodb table that stores the terraform locks"
}
