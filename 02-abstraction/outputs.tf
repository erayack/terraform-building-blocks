output "bucket_name" {
  description = "Created S3 bucket name."
  value       = aws_s3_bucket.artifact.bucket
}

output "deployment_identity" {
  description = "Account and region Terraform planned against."
  value = {
    account_id = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
  }
}
