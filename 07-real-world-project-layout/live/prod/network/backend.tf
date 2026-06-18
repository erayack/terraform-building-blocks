terraform {
  required_version = ">= 1.6.0"

  # Example only. Uncomment after creating the real backend bucket/table.
  # backend "s3" {
  #   bucket         = "my-company-terraform-state"
  #   key            = "prod/network/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
