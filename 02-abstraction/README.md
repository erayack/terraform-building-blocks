# Level 2: Abstraction

Level 1 proved that Terraform can create infrastructure. Level 2 makes the code configurable, readable, and useful to other systems.

The core idea is separation:

- Inputs belong in `variable` blocks.
- Repeated internal expressions belong in `locals`.
- Existing/provider information belongs in `data` blocks.
- Useful results belong in `output` blocks.

This is the first step from a script toward reusable infrastructure code.

## Files in this level

```text
main.tf       # provider, data sources, locals, resources
variables.tf  # input contract
outputs.tf    # values returned by the configuration
README.md
```

Terraform automatically loads all `.tf` files in a directory. File names are for humans; Terraform treats them as one module.

## Block: `variable`

```hcl
variable "project" {
  description = "Short project name used in resource names and tags."
  type        = string
}
```

A variable declares an input. The syntax is:

```hcl
variable "NAME" {
  description = "human-readable explanation"
  type        = TYPE
  default     = optional_default
}
```

If a variable has no `default`, the caller must provide it.

Ways to provide variable values:

```bash
terraform plan -var='project=demo' -var='environment=dev'
```

or with a file:

```hcl
# dev.tfvars
project     = "demo"
environment = "dev"
```

then:

```bash
terraform plan -var-file=dev.tfvars
```

## Variable validation

```hcl
validation {
  condition     = contains(["dev", "test", "prod"], var.environment)
  error_message = "environment must be one of: dev, test, prod."
}
```

Validation catches bad input at the boundary. This is better than letting invalid names or unsafe values flow through the configuration.

The expression:

```hcl
var.environment
```

means: read the value of the variable named `environment`.

## Block: `locals`

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

Locals are internal names for expressions. They are not inputs. They cannot be overridden from the CLI.

Use locals when:

- a value is repeated,
- a name expression is long,
- a map of tags should stay consistent,
- an expression needs a meaningful name.

Reference locals with:

```hcl
local.name_prefix
local.common_tags
```

Notice the singular `local`, not `locals`.

## Block: `data`

```hcl
data "aws_caller_identity" "current" {}
```

A data source reads information instead of creating it.

A resource says:

> Create or manage this object.

A data source says:

> Look up this information and make it available.

In this level:

```hcl
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
```

These let Terraform discover the AWS account and region.

Reference data sources like this:

```hcl
data.aws_caller_identity.current.account_id
data.aws_region.current.name
```

## Block: `output`

```hcl
output "bucket_name" {
  description = "Created S3 bucket name."
  value       = aws_s3_bucket.artifact.bucket
}
```

Outputs are return values from a Terraform module.

They are useful for:

- humans reading `terraform apply` results,
- scripts that call Terraform,
- parent modules that need child module values,
- CI/CD systems that publish deployment metadata.

View outputs after apply:

```bash
terraform output
terraform output bucket_name
```

Machine-readable output:

```bash
terraform output -json
```

## Types

This level uses simple types:

```hcl
type = string
```

Terraform also supports:

```hcl
type = number
type = bool
type = list(string)
type = map(string)
type = object({ name = string, enabled = bool })
```

Types are part of your module contract. Good types make a module harder to misuse.

## Resource arguments using abstractions

Instead of this hardcoded Level 1 style:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Level 2 uses:

```hcl
provider "aws" {
  region = var.aws_region
}
```

Instead of repeating tags in every resource, use:

```hcl
tags = local.common_tags
```

## Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var='project=demo' -var='environment=dev'
```

Optional with a tfvars file:

```bash
cat > dev.tfvars <<'EOF'
project     = "demo"
environment = "dev"
EOF

terraform plan -var-file=dev.tfvars
```

## What you should understand before moving on

You should be able to explain:

1. Why variables are a module's input contract.
2. Why locals are different from variables.
3. Why data sources are safer than hardcoding external IDs.
4. How outputs expose useful results.
5. How validation protects the boundary of a configuration.
