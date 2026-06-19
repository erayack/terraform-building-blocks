# Level 6: Operations Platform

Level 6 treats Terraform as part of an operating model.

The earlier levels answer:

> How do I write Terraform code?

This level answers:

> How do teams safely change infrastructure over time?

The important building blocks are CI/CD, tests, drift detection, promotion, and observability.

## Files in this level

```text
main.tf
ci/
  github-actions.yml
tests/
  release.tftest.hcl
README.md
```

The workflow file is kept under `ci/` as book/source material. It will not run automatically from this location. If you want GitHub Actions to execute it in a real repository, copy it to `.github/workflows/terraform-platform.yml`.

## CI/CD pipeline shape

A common Terraform pipeline has these stages:

1. Format check.
2. Initialize providers.
3. Validate syntax and schemas.
4. Run tests.
5. Create a plan.
6. Check policy.
7. Require human or automated approval.
8. Apply.
9. Publish outputs and metadata.

This repository shows the early safe stages:

```yaml
- name: Terraform fmt
  run: terraform fmt -check -recursive

- name: Terraform init
  working-directory: 06-operations-platform
  run: terraform init

- name: Terraform validate
  working-directory: 06-operations-platform
  run: terraform validate

- name: Terraform test
  working-directory: 06-operations-platform
  run: terraform test

- name: Terraform plan
  working-directory: 06-operations-platform
  run: terraform plan -out=tfplan
```

For learning, this pipeline does not apply automatically. That is intentional. Plans are safer to review than blind applies.

## Terraform native tests

Terraform supports `.tftest.hcl` files.

This level includes:

```text
tests/release.tftest.hcl
```

The test contains:

```hcl
run "release_name_contains_service" {
  command = plan

  assert {
    condition     = startswith(output.release_name, "payments-")
    error_message = "release_name must start with the service name."
  }
}
```

A `run` block defines a test run.

```hcl
command = plan
```

means Terraform should run a plan, not an apply.

The `assert` block checks an expression.

```hcl
startswith(output.release_name, "payments-")
```

checks that the output value has the expected prefix.

Run tests locally:

```bash
terraform init
terraform test
```

## Outputs as contracts

In `main.tf`:

```hcl
output "release_name" {
  value = "${var.service_name}-${random_pet.release.id}"
}
```

Outputs become part of how other systems consume Terraform.

For example, a deployment pipeline might read:

```bash
terraform output -json
```

and publish release metadata.

That means output names and shapes should be treated like contracts. Changing an output can break downstream automation.

## Drift detection

Drift means real infrastructure no longer matches Terraform's expected state.

Examples:

- someone changed a setting in the AWS console,
- an emergency script modified infrastructure,
- an external controller changed tags or policies,
- a resource was deleted manually.

The example workflow includes a scheduled trigger:

```yaml
schedule:
  - cron: "0 6 * * *"
```

If copied into `.github/workflows/`, this would run a plan every morning. In a real platform, the result could notify Slack, open an issue, or block promotion.

Drift detection usually runs:

```bash
terraform plan -detailed-exitcode
```

Exit codes:

| Code | Meaning |
|---|---|
| 0 | No changes |
| 1 | Error |
| 2 | Changes detected |

## Promotion

Promotion means moving a known-good infrastructure version from one environment to another.

A mature flow might be:

```text
development -> test -> staging -> production
```

Good promotion usually promotes the same module version, not copied code.

Example approach:

```text
modules/network version v1.2.0 tested in dev
modules/network version v1.2.0 promoted to staging
modules/network version v1.2.0 promoted to prod
```

This is safer than making different manual edits in every environment.

## Observability and ownership

Infrastructure should be understandable after it exists.

Common metadata:

- owner,
- service name,
- environment,
- cost center,
- repository,
- run ID,
- module version.

This level has simple variables:

```hcl
variable "service_name" {
  type    = string
  default = "payments"
}

variable "owner" {
  type    = string
  default = "platform-team@example.com"
}
```

In cloud resources, these often become tags. In this small example they are used as `keepers` for a random resource.

## `random_pet` and `keepers`

```hcl
resource "random_pet" "release" {
  length = 2

  keepers = {
    service = var.service_name
    owner   = var.owner
  }
}
```

`random_pet` creates a readable random name.

`keepers` decide when the random value should be replaced. If a keeper changes, Terraform creates a new random value.

This is useful for learning because it creates a resource without needing a cloud account.

## Platform lesson

Terraform at platform scale is less about writing more HCL and more about building safe paths:

- developers can propose changes,
- automation checks the changes,
- policies enforce boundaries,
- plans are reviewed,
- applies are auditable,
- drift is detected,
- outputs are consumed consistently.

## Commands

```bash
terraform init
terraform fmt
terraform validate
terraform test
terraform plan
```

For drift-style behavior locally:

```bash
terraform plan -detailed-exitcode
```

## What you should understand after this level

You should be able to explain:

1. Why Terraform belongs in CI/CD.
2. What Terraform native tests can verify.
3. What drift is and how scheduled plans detect it.
4. Why outputs are contracts for other systems.
5. Why promotion should move versions, not copy-pasted code.
