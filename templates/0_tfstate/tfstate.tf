# 1_network
# terraform init --backend-config=backend.hcl

#-------------
#--- Variables
#-------------


#------------
#--- Provider
#------------


#-------------
#--- Resources
#-------------

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-${var.account}-${var.region}"

  # prevent accidental deletion of this bucket
  # (if you really have to destroy this bucket, change this value to false and reapply)
  lifecycle {
    prevent_destroy = true
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
  name = "tfstate-${var.region}"
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