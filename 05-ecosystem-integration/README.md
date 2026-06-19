# Level 5: Ecosystem Integration

At this level Terraform is no longer just a command you run locally. It becomes part of a larger delivery system.

Terraform is good at creating infrastructure. It is not the best tool for every job. Real platforms often combine it with:

- shell scripts,
- Ansible,
- CI/CD pipelines,
- Terragrunt,
- policy engines such as OPA or Sentinel,
- environment workflows such as dev/test/prod.

This level shows small learning examples of those integration points.

## Files in this level

```text
main.tf
playbook.yml
policy/
  s3-encryption.rego
live/
  dev/
    terragrunt.hcl
README.md
```

## Workspaces

Terraform workspaces let one configuration have multiple state instances.

The current workspace is available as:

```hcl
terraform.workspace
```

This level uses:

```hcl
locals {
  environment = terraform.workspace
}
```

If you select the `dev` workspace, then:

```hcl
local.environment
```

will be `dev`.

Commands:

```bash
terraform workspace list
terraform workspace new dev
terraform workspace select dev
```

Workspaces are useful for learning and for some small workflows. Large production systems often prefer separate directories, accounts, or backend keys for stronger environment isolation.

## Provisioners

```hcl
resource "null_resource" "handoff_to_configuration" {
  triggers = {
    environment = local.environment
    playbook_sha = filesha256("${path.module}/playbook.yml")
  }

  provisioner "local-exec" {
    command = "echo Run Ansible or Bash bootstrap for ${self.triggers.environment}"
  }
}
```

Provisioners run commands as part of Terraform operations.

This example uses `local-exec`, which runs on the machine executing Terraform.

Syntax:

```hcl
provisioner "local-exec" {
  command = "some shell command"
}
```

Provisioners are a last resort. Prefer:

- machine images,
- cloud-init/user data,
- Kubernetes controllers,
- Ansible or configuration management outside Terraform,
- CI/CD deployment stages.

Why? Because provisioners can make Terraform harder to retry, test, and reason about.

## `null_resource`

`null_resource` does not create cloud infrastructure. It exists to participate in Terraform's graph.

Its `triggers` argument decides when it should be replaced:

```hcl
triggers = {
  playbook_sha = filesha256("${path.module}/playbook.yml")
}
```

If `playbook.yml` changes, the hash changes, so Terraform replaces the `null_resource` and re-runs the provisioner.

Important functions:

```hcl
path.module
```

is the filesystem path of the current module.

```hcl
filesha256("file")
```

returns a hash of a file's contents.

```hcl
self.triggers.environment
```

references the current resource instance inside a provisioner.

## Terragrunt

Terragrunt is a wrapper around Terraform. It is often used to keep multi-environment infrastructure DRY.

The example file is:

```text
live/dev/terragrunt.hcl
```

It contains:

```hcl
terraform {
  source = "../../"
}
```

This tells Terragrunt to run the Terraform code two directories up.

Try:

```bash
cd live/dev
terragrunt plan
```

For real systems, Terragrunt commonly manages:

- remote state configuration,
- shared inputs,
- module version pinning,
- account/region layouts,
- dependency outputs between stacks.

## Policy as code

Policy as code checks whether a Terraform plan follows rules before it is applied.

Example rule:

> Every newly-created S3 bucket must have server-side encryption configured.

This repository includes a tiny OPA/Rego example:

```text
policy/s3-encryption.rego
```

The policy reads Terraform plan JSON, not `.tf` files directly.

Generate a plan JSON:

```bash
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
```

Evaluate the policy:

```bash
opa eval --input plan.json --data policy/s3-encryption.rego 'data.terraform.policy.deny'
```

If the `deny` set is empty, the plan passed this particular rule. If it contains messages, the plan violated the rule.

## OPA syntax in the example

```rego
deny[msg] {
  bucket := input.resource_changes[_]
  bucket.type == "aws_s3_bucket"
  bucket.change.actions[_] == "create"

  bucket_name := bucket.change.after.bucket
  not encrypted_bucket[bucket_name]

  msg := sprintf("S3 bucket %s must have server-side encryption configured", [bucket.address])
}
```

Read this as:

> For each resource change, if it is a created S3 bucket and no matching encryption configuration exists, add a denial message.

This is intentionally small for learning. Production policy libraries need more edge-case handling.

### Limitation of this example policy

The example policy matches buckets and encryption configuration using the planned bucket name/id:

```rego
bucket.change.after.bucket
```

That keeps the policy readable, but it is not a complete production-grade approach. In real Terraform plans, some values may be unknown until apply time, especially when names are built from generated resources such as `random_id`. A production policy would usually inspect more of the Terraform plan structure, resource addresses, configuration references, or provider-specific edge cases.

For this chapter, the goal is not to write a perfect S3 policy. The goal is to understand the platform pattern:

```text
terraform plan -> plan JSON -> policy evaluation -> allow or deny
```

## Sentinel vs OPA

Both are policy-as-code tools.

| Tool | Common context |
|---|---|
| Sentinel | HashiCorp Cloud Platform / Terraform Enterprise |
| OPA/Rego | General-purpose policy engine used across many systems |

The concept is the same: turn organizational rules into versioned code.

## Commands

```bash
terraform workspace new dev || terraform workspace select dev
terraform init
terraform plan
```

Try the OPA policy example:

```bash
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
opa eval --input plan.json --data policy/s3-encryption.rego 'data.terraform.policy.deny'
```

Try the Terragrunt example:

```bash
cd live/dev
terragrunt plan
```

## What you should understand before moving on

You should be able to explain:

1. What workspaces change: state, not code.
2. Why provisioners should be used sparingly.
3. How `null_resource.triggers` causes re-execution.
4. What Terragrunt adds around Terraform.
5. Why policy should check plans before apply.
