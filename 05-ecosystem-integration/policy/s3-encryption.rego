package terraform.policy

# Example OPA policy for `terraform show -json plan.out` input.
# It is intentionally small for learning: every newly-created S3 bucket must
# have a matching aws_s3_bucket_server_side_encryption_configuration in the
# same plan whose `bucket` argument points at that bucket name/id.

deny[msg] {
  bucket := input.resource_changes[_]
  bucket.type == "aws_s3_bucket"
  bucket.change.actions[_] == "create"

  bucket_name := bucket.change.after.bucket
  not encrypted_bucket[bucket_name]

  msg := sprintf("S3 bucket %s must have server-side encryption configured", [bucket.address])
}

encrypted_bucket[bucket_name] {
  enc := input.resource_changes[_]
  enc.type == "aws_s3_bucket_server_side_encryption_configuration"
  enc.change.actions[_] == "create"

  bucket_name := enc.change.after.bucket
}
