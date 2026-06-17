# Level 3 — The Structural

Level 3 is about shape. Terraform projects become easier to reason about when related resources are packaged together and state is treated as shared infrastructure metadata.

The two big concepts are:

1. **Modules**: reusable packages of Terraform code.
2. **State/backends**: Terraform's memory and where that memory is stored.

## Files in this level

```text
backend.tf
main.tf
variables.tf
outputs.tf
modules/
  static-site/
    main.tf
    variables.tf
    outputs.tf
```

The root module calls a child module:

```hcl
module "static_site" {
  source = "./modules/static-site"

  project     = var.project
  environment = var.environment
}
```

## Root module vs child module

Every Terraform directory is a module.

The directory where you run Terraform is called the **root module**.

A directory called by another module is a **child module**.

In this level:

```text
03-structural/                  # root module
03-structural/modules/static-site/ # child module
```

## Block: `module`

```hcl
module "static_site" {
  source = "./modules/static-site"

  project     = var.project
  environment = var.environment
}
```

A module block creates an instance of another Terraform module.

Syntax:

```hcl
module "LOCAL_NAME" {
  source = "PATH_OR_REGISTRY_ADDRESS"

  input_name = input_value
}
```

`source` can point to:

- a local path: `./modules/static-site`
- a Git repository
- a Terraform registry module
- a versioned module source

For learning, local paths are easiest.

## Child module inputs

Inside `modules/static-site/variables.tf`:

```hcl
variable "project" {
  type = string
}

variable "environment" {
  type = string
}
```

The child module declares what it needs. The root module passes those values in the `module` block.

This is like a function call:

```text
static_site(project, environment)
```

## Child module outputs

Inside `modules/static-site/outputs.tf`:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
```

The root module can read that output as:

```hcl
module.static_site.bucket_name
```

That is why the root `outputs.tf` can contain:

```hcl
output "site_bucket_name" {
  value = module.static_site.bucket_name
}
```

Outputs are how information crosses module boundaries.

## Resource naming inside modules

The module uses local names like:

```hcl
resource "aws_s3_bucket" "this" {
```

`this` is a common convention inside small modules. It means "the main resource of this module."

From outside the module, Terraform addresses it with the module path:

```text
module.static_site.aws_s3_bucket.this
```

This keeps resources organized even when many modules contain resources named `this`.

## State: Terraform's memory

Terraform state records the mapping between configuration and real infrastructure.

For example, Terraform needs to remember:

```text
aws_s3_bucket.this -> actual AWS bucket named demo-dev-site-abcd1234
```

Without state, Terraform would not know whether a resource already exists, should be updated, or should be destroyed.

Local state is usually stored in:

```text
terraform.tfstate
```

Do not edit state by hand while learning unless you are intentionally studying recovery.

## Why remote state matters

Local state is okay for solo experiments. Teams need remote state because:

- everyone must see the same infrastructure memory,
- state can contain sensitive data,
- concurrent applies must be prevented,
- state should be backed up.

A common AWS backend is:

```hcl
backend "s3" {
  bucket         = "my-company-terraform-state"
  key            = "static-site/dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

## Block: backend configuration

This repo keeps the backend commented out:

```hcl
# backend "s3" {
#   bucket = "my-company-terraform-state"
# }
```

Why? Because Terraform must initialize the backend before it can use it, and the backend bucket/table must already exist.

This bootstrapping problem is normal:

1. Create backend infrastructure separately.
2. Uncomment backend config.
3. Run `terraform init`.
4. Terraform migrates or initializes state in the backend.

## Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var='project=demo' -var='environment=dev'
```

If you later enable the S3 backend:

```bash
terraform init -migrate-state
```

## Design lesson

A module should hide implementation details but expose useful inputs and outputs.

Bad module design:

- too many unrelated resources,
- no clear purpose,
- outputs every internal value,
- hardcodes environment-specific values.

Good module design:

- one clear responsibility,
- typed inputs,
- meaningful outputs,
- safe defaults,
- documented behavior.

## What you should understand before moving on

You should be able to explain:

1. The difference between root and child modules.
2. How module inputs and outputs work.
3. What Terraform state stores.
4. Why remote backends are important for teams.
5. Why backend infrastructure has to exist before it can store state.
