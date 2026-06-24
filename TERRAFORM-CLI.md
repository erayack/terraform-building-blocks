# Terraform CLI Guide

This guide is the command-line companion to the eight Terraform levels in this repository.

The level READMEs explain Terraform building blocks. This file explains the commands you use to work with those building blocks safely.

## Mental model

Most Terraform work follows this loop:

```text
write configuration -> init -> format -> validate -> plan -> apply -> inspect -> destroy when done
```

Terraform commands are safest when you separate **planning** from **applying**.

A plan answers:

> What would Terraform change?

An apply answers:

> Make those changes now.

## First-time workflow

From any level directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

Only apply if you understand the plan:

```bash
terraform apply
```

Clean up learning resources:

```bash
terraform destroy
```

## `terraform init`

Initializes a Terraform working directory.

```bash
terraform init
```

It downloads providers, installs modules, and configures the backend.

Run it when:

- you enter a Terraform directory for the first time,
- provider versions change,
- modules are added or changed,
- backend configuration changes.

Useful flags:

```bash
terraform init -upgrade
terraform init -reconfigure
terraform init -migrate-state
```

Meanings:

| Command | Use when |
|---|---|
| `-upgrade` | You want the newest allowed provider/module versions |
| `-reconfigure` | Backend settings changed and should be re-read |
| `-migrate-state` | You are moving existing state to a new backend |

## `terraform fmt`

Formats Terraform files.

```bash
terraform fmt
```

Format recursively from the repo root:

```bash
terraform fmt -recursive
```

Check formatting in CI without changing files:

```bash
terraform fmt -check -recursive
```

## `terraform validate`

Checks whether the configuration is syntactically valid and internally consistent.

```bash
terraform validate
```

Validation does not guarantee the provider API will accept every setting. It catches Terraform-level mistakes before planning.

## `terraform plan`

Shows what Terraform intends to change.

```bash
terraform plan
```

Save a plan file:

```bash
terraform plan -out=tfplan
```

Then apply exactly that saved plan:

```bash
terraform apply tfplan
```

This is safer than running `terraform apply` later and letting Terraform create a fresh, possibly different plan.

## Reading a plan

Terraform plan symbols:

| Symbol | Meaning |
|---|---|
| `+` | Create |
| `~` | Update in place |
| `-/+` | Destroy and recreate |
| `-` | Destroy |
| `<=` | Read data source |

Pay special attention to:

- resources being destroyed,
- replacements (`-/+`),
- security-related changes,
- public access changes,
- IAM policy changes,
- database/storage changes.

## `terraform apply`

Applies changes.

Interactive apply:

```bash
terraform apply
```

Apply a saved plan:

```bash
terraform apply tfplan
```

Auto-approve is useful in automation, but risky while learning:

```bash
terraform apply -auto-approve
```

Prefer reviewing plans manually until you are comfortable.

## `terraform destroy`

Destroys resources managed by the current state.

```bash
terraform destroy
```

Preview destruction first:

```bash
terraform plan -destroy
```

Destroy is important for learning because cloud resources can cost money.

If a resource has `prevent_destroy = true`, Terraform will refuse to destroy it until that lifecycle rule is removed.

## Variables from the CLI

Pass individual variables:

```bash
terraform plan -var='project=demo' -var='environment=dev'
```

Use a variable file:

```bash
terraform plan -var-file=dev.tfvars
```

Example `dev.tfvars`:

```hcl
project     = "demo"
environment = "dev"
aws_region  = "us-east-1"
```

Common file names:

```text
terraform.tfvars
dev.tfvars
prod.tfvars
```

Terraform automatically loads:

```text
terraform.tfvars
*.auto.tfvars
```

Other files must be passed with `-var-file`.

## Outputs

Show all outputs:

```bash
terraform output
```

Show one output:

```bash
terraform output bucket_name
```

Get JSON output for scripts:

```bash
terraform output -json
```

Outputs are useful after apply. Before apply, some output values may be unknown.

## State inspection

List resources in state:

```bash
terraform state list
```

Show one resource from state:

```bash
terraform state show aws_s3_bucket.example
```

State commands inspect Terraform's memory. They do not directly query every live cloud setting.

Be careful with state-changing commands such as:

```bash
terraform state rm
terraform state mv
terraform import
```

Those are useful, but they can confuse Terraform if used without understanding.

## Providers and modules

Show required providers:

```bash
terraform providers
```

Show dependency lock information:

```bash
cat .terraform.lock.hcl
```

The lock file records exact provider versions selected during init. Commit it in real projects.

## Workspaces

List workspaces:

```bash
terraform workspace list
```

Create a workspace:

```bash
terraform workspace new dev
```

Select a workspace:

```bash
terraform workspace select dev
```

Show current workspace:

```bash
terraform workspace show
```

Workspaces create separate state instances for the same configuration.

Learning rule:

> Workspaces change state, not code.

## Tests

Run Terraform native tests:

```bash
terraform test
```

Run one test file:

```bash
terraform test -filter=tests/release.tftest.hcl
```

Tests are useful for checking module contracts, outputs, validations, and assumptions.

## Drift detection

To check for drift against live infrastructure without proposing configuration changes, use a refresh-only plan:

```bash
terraform plan -refresh-only
```

In CI, combine refresh-only mode with detailed exit codes:

```bash
terraform plan -refresh-only -detailed-exitcode
```

Exit codes:

| Code | Meaning |
|---|---|
| `0` | No changes |
| `1` | Error |
| `2` | Changes detected |

This is useful in CI because automation can distinguish failure from drift.

Example shell pattern:

```bash
terraform plan -refresh-only -detailed-exitcode
code=$?

if [ "$code" -eq 0 ]; then
  echo "No drift"
elif [ "$code" -eq 2 ]; then
  echo "Drift detected"
else
  echo "Terraform error"
  exit 1
fi
```

## Plan JSON

Create a binary plan:

```bash
terraform plan -out=plan.out
```

Convert it to JSON:

```bash
terraform show -json plan.out > plan.json
```

Plan JSON is commonly used by:

- policy checks,
- cost estimation tools,
- security scanners,
- custom CI scripts.

## Targeting warning

Terraform supports targeting one resource:

```bash
terraform plan -target=aws_s3_bucket.example
```

Use this sparingly.

`-target` can be useful for recovery or unusual migration work, but it bypasses Terraform's normal full-graph planning. It can hide changes elsewhere.

Learning rule:

> If you reach for `-target`, ask why a normal plan is not enough.

## Replace one resource

Force Terraform to replace a resource:

```bash
terraform apply -replace=aws_instance.example
```

This is safer and clearer than older workflows involving `terraform taint`.

Use replacement when you intentionally want to recreate something even if Terraform does not think it must be replaced.

## Importing existing resources

Import connects an existing real-world object to Terraform state.

```bash
terraform import aws_s3_bucket.example my-existing-bucket-name
```

Import does not automatically write full Terraform configuration for you. You still need matching `.tf` code.

Basic import workflow:

```text
write resource block -> terraform import -> terraform plan -> adjust code until plan is clean
```

## Common safe workflows

### Learning workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Team pull request workflow

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform test
terraform plan -out=tfplan
```

### Scheduled drift workflow

```bash
terraform init
terraform plan -refresh-only -detailed-exitcode
```

### Saved plan workflow

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Cleanup workflow

```bash
terraform plan -destroy
terraform destroy
```

### Policy workflow

```bash
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
opa eval --input plan.json --data policy/s3-encryption.rego 'data.terraform.policy.deny'
```

## Troubleshooting

### Provider not installed

Run:

```bash
terraform init
```

### Formatting failed in CI

Run locally:

```bash
terraform fmt -recursive
```

### Variable value missing

Pass it:

```bash
terraform plan -var='project=demo'
```

or create a tfvars file.

### Backend changed

Depending on the situation:

```bash
terraform init -reconfigure
terraform init -migrate-state
```

### Resource already exists

Options:

1. Choose a different name.
2. Import the existing resource.
3. Delete the existing resource manually if it is safe.

## Retrieval practice

Before moving on, answer from memory:

1. What is the difference between `validate`, `plan`, and `apply`?
2. Why is `terraform plan -out=tfplan` safer before applying?
3. What does `terraform state list` show?
4. What does `-detailed-exitcode` add for CI?
5. Why should `-target` be used rarely?
