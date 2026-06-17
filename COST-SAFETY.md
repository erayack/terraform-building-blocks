# Cost and Safety Guide

Terraform can create real cloud resources. This repository is for learning, but some examples still touch AWS.

Read this before running `terraform apply`.

## Which levels may create AWS resources?

| Level | Uses AWS? | Notes |
|---|---:|---|
| `01-foundation` | Yes | Creates an S3 bucket and related bucket settings |
| `02-abstraction` | Yes | Creates an S3 bucket and reads account/region data |
| `03-structural` | Yes | Creates an S3 bucket through a module |
| `04-dynamic` | Yes | Creates VPC, subnets, security group, optional log group |
| `05-ecosystem-integration` | No cloud resources by default | Uses `null_resource`; OPA/Terragrunt examples are workflow-focused |
| `06-operations-platform` | No AWS | Uses the `random` provider only |

## Golden rule

Always run a plan before apply:

```bash
terraform plan
```

Read the plan. Look especially for:

- creates: `+`
- updates: `~`
- replacements: `-/+`
- destroys: `-`

## Clean up learning resources

After applying an AWS-backed level, clean it up:

```bash
terraform destroy
```

For a safer preview:

```bash
terraform plan -destroy
```

## Watch for `prevent_destroy`

`04-dynamic` includes a lifecycle example:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This teaches safety behavior, but it can block cleanup. If `terraform destroy` fails because of `prevent_destroy`, remove or comment out that lifecycle block, then run destroy again.

## S3 bucket names are global

S3 bucket names must be globally unique across AWS.

This repo uses random suffixes where appropriate to reduce name collisions.

If you see a bucket-name conflict, change the project/environment values or re-run with a different random suffix after cleanup.

## Do not commit secrets

Never commit:

```text
*.tfstate
*.tfstate.backup
*.tfvars with secrets
.terraform/
AWS credentials
private keys
```

Terraform state may contain sensitive values. Treat it as private infrastructure data.

## Prefer saved plans for careful applies

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

This ensures Terraform applies exactly the reviewed plan.

## Be careful with public access

The S3 examples include public access blocks. Keep them enabled unless you are intentionally learning about public hosting and understand the risks.

## Region and account check

Before applying, confirm where you are deploying:

```bash
aws sts get-caller-identity
aws configure get region
```

Terraform can also show account/region data in Level 2 outputs after apply.

## Cost cleanup checklist

Before stopping a learning session:

1. Run `terraform destroy` in any level where you ran `terraform apply`.
2. Check the AWS console for leftover resources.
3. Remove local plan files if you do not need them:

```bash
rm -f tfplan plan.out plan.json
```

4. Keep `.terraform.lock.hcl` in real repos, but do not commit `.terraform/`.
