# Level 1 — The Foundation

Terraform begins with three simple ideas: choose a provider, describe a resource, and give Terraform enough literal configuration to call the provider API.

At this level we intentionally avoid cleverness. No variables, no modules, no loops. The goal is to see the smallest useful Terraform program.

## Mental model

Terraform is a desired-state tool. You write configuration that says:

> I want this infrastructure object to exist with these settings.

Terraform then compares your configuration with its state file and with the cloud provider, builds an execution plan, and applies the changes.

## Files in this level

```text
main.tf
README.md
```

Everything is in `main.tf` so the basic structure is easy to see.

## Block: `terraform`

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

The `terraform` block configures Terraform itself.

Important syntax:

- `required_version` says which Terraform CLI versions may run this code.
- `required_providers` declares provider plugins.
- `source = "hashicorp/aws"` means download the AWS provider from the HashiCorp registry.
- `version = "~> 5.0"` allows compatible `5.x` versions.

Terraform does not include AWS support by default. Providers are plugins.

## Block: `provider`

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider block configures how Terraform talks to AWS.

Here, the region is hardcoded. That is acceptable for first learning because it removes indirection. Later levels replace this with variables.

Provider credentials are normally loaded from the AWS CLI environment, for example:

```bash
aws configure
```

or environment variables such as:

```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

## Block: `resource`

```hcl
resource "aws_s3_bucket" "foundation" {
  bucket = "terraform-foundation-example"
}
```

A resource block has two labels:

```hcl
resource "TYPE" "LOCAL_NAME" {
  argument = value
}
```

In this repository:

```hcl
resource "aws_s3_bucket" "foundation"
```

means:

- `aws_s3_bucket`: the provider resource type.
- `foundation`: the local Terraform name.

Terraform references this object as:

```hcl
aws_s3_bucket.foundation
```

The local name is not necessarily the cloud name. It is the name Terraform uses inside the configuration.

## Attribute references

This level uses references like:

```hcl
bucket = aws_s3_bucket.foundation.id
```

This means: take the `id` attribute from the S3 bucket resource and use it as the `bucket` argument for another resource.

Terraform builds a dependency graph from references. If resource B refers to resource A, Terraform knows A must be created first.

## Hardcoded values

Examples of hardcoded values in this level:

```hcl
region        = "us-east-1"
sse_algorithm = "AES256"
byte_length   = 4
```

Hardcoding is not reusable, but it is useful while learning because every value is visible where it is used.

The tradeoff:

| Benefit | Cost |
|---|---|
| Easy to read | Hard to reuse |
| No extra files | Hard to change per environment |
| Good for first examples | Not good for teams |

## Why `random_id` exists

S3 bucket names must be globally unique across AWS. If the example used a fixed bucket name, many learners would collide with each other.

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}
```

Then the bucket name includes that random suffix:

```hcl
bucket = "terraform-foundation-${random_id.suffix.hex}"
```

The `${...}` syntax is string interpolation. It inserts an expression into a string.

## Commands

Initialize providers:

```bash
terraform init
```

Format files:

```bash
terraform fmt
```

Check syntax and provider schemas:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Apply only if you are comfortable creating resources:

```bash
terraform apply
```

Clean up:

```bash
terraform destroy
```

## What you should understand before moving on

You should be able to explain:

1. What a provider does.
2. What a resource block represents.
3. Why Terraform can infer dependencies from references.
4. Why hardcoded values are simple but not reusable.
5. Why `terraform plan` is safer than immediately applying.
