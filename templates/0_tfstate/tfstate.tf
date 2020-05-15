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

# locals {
#   sftp_bucket = "tfstate-${data.aws_caller_identity.current.account_id}"
# }


#-------------
#--- Resources
#-------------

resource "aws_s3_bucket_public_access_block" "sftp_bucket_block_public_access" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  # Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. 
  # Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to:
  # Reject calls to PUT Bucket policy if the specified bucket policy allows public access.
  block_public_acls       = true

  # Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. 
  # Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to:
  # Reject calls to PUT Bucket policy if the specified bucket policy allows public access.
  block_public_policy     = true

  # Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to false. 
  # Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set. When set to true causes Amazon S3 to:
  # Ignore public ACLs on this bucket and any objects that it contains.
  ignore_public_acls      = true

  # Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to false. 
  # Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, 
  # including non-public delegation to specific accounts, is blocked. When set to true:
  # Only the bucket owner and AWS Services can access this buckets if it has a public policy.
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.bucket

  # The canned ACL to apply. Defaults to "private". Conflicts with grant.
  # "private": Owner gets FULL_CONTROL. No one else has access rights (default).
  acl = "private"

  # A boolean that indicates all objects (including any locked objects) should be deleted from the bucket 
  # so that the bucket can be destroyed without error. These objects are not recoverable.
  force_destroy = true

  # prevent accidental deletion of this bucket
  # (if you really have to destroy this bucket, change this value to false and reapply, then run destroy)
  lifecycle {
    prevent_destroy = false
  }

  # enable versioning so we can see the full revision history of our state file
  versioning {
    enabled = false
  }

  # enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # kms_master_key_id = aws_kms_key.ROOT-KMS-S3.arn
        # sse_algorithm     = "aws:kms"
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
