---
name: terraform-iac-skill
description: Use when writing, reviewing, debugging, or teaching Terraform/OpenTofu code, modules, state, tests, CI/CD, and security controls. Diagnose risk before proposing changes.
license: Apache-2.0
metadata:
  source: Inspired by antonbabenko/terraform-skill
---

# Terraform / OpenTofu Skill

Use this skill for Terraform or OpenTofu work in this repository: creating infrastructure code, reviewing modules, debugging plans, improving state layout, writing tests, and setting up CI/CD or security scanning.

## Response Contract

For Terraform/OpenTofu tasks, include these points in the answer or implementation notes:

1. **Assumptions and version floor**
   - Runtime: `terraform` or `tofu`
   - Version, providers, backend, execution path: local / CI / Terraform Cloud / Atlantis
   - Environment criticality: sandbox / dev / staging / prod
2. **Risk category addressed**
   - Identity churn
   - Secret exposure
   - Blast radius
   - CI drift
   - Compliance gaps
   - State corruption
   - Provider upgrade risk
   - Testing blind spots
3. **Remediation and tradeoffs**
   - State what changed, why it is safer, and what tradeoff remains.
4. **Validation plan**
   - Give exact commands such as `terraform fmt -check`, `terraform validate`, `terraform plan -out=tfplan`, `terraform test`, `tflint`, `trivy config .`, or `checkov -d .`.
5. **Rollback notes**
   - For destructive or state-mutating changes, explain how to undo the change and what evidence/artifacts to keep.

Never recommend direct production apply without a reviewed plan artifact and approval.

Never run or recommend `terraform destroy`/`tofu destroy` without first running a destroy plan and explicitly reviewing every resource that will be deleted. Do not use `-auto-approve` for destroy.

## Workflow

1. Capture context: runtime, versions, providers, backend, environment, and execution path.
2. Diagnose the likely failure/risk mode before generating code.
3. Make the smallest safe change.
4. Prefer stable identities and reviewable migrations over recreate-in-place refactors.
5. Generate code, migration blocks, imports, tests, CI changes, or policy rules.
6. Validate with the commands appropriate to the risk level.
7. Summarize risks, validation, and rollback.

## Risk Routing

| Category | Common symptoms | Preferred response |
| --- | --- | --- |
| Identity churn | `count` index changes, resource address refactors, unexpected destroy/create | Prefer `for_each` with stable keys, add `moved` blocks, verify plan has no unintended destroy |
| Secret exposure | Secrets in variables, tfvars, state, logs, CI artifacts | Keep secrets out of Terraform where possible, use secret managers, mark sensitive outputs, consider write-only args when supported |
| Blast radius | Huge states, shared prod/non-prod, unrelated resources in one plan | Split by environment/component/team lifecycle; require reviewed plan artifacts |
| CI drift | Local plan differs from CI, unpinned versions, apply re-plans | Pin runtime/providers, commit lockfile, apply the reviewed plan artifact |
| Compliance gaps | No policy checks, no approvals, no evidence retention | Add scanning/policy stage and protected apply workflow |
| Testing blind spots | Only `validate`, no module tests, assertions against computed values in plan-only tests | Add native tests or Terratest; use apply tests for computed values |
| State corruption | Stuck locks, bad imports, backend migration, manual state edits | Back up state, use locks, prefer declarative `import`, `moved`, and `removed` blocks |
| Provider upgrade risk | Major provider bump, unpinned modules, breaking plan | Separate upgrade PRs, read changelog, pin versions, compare plan before/after |

## Module Structure

Recommended layout:

```text
modules/
  <module>/
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    README.md
    examples/
      minimal/
      complete/
    tests/
      <module>.tftest.hcl
environments/
  dev/
  staging/
  prod/
```

Keep modules small and focused. Separate reusable modules from deployable environment compositions.

## Naming and File Conventions

- Use standard files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
- Use descriptive resources: `aws_instance.web_server`, not `aws_instance.main`, unless a module truly has a single primary resource where `this` is clearer.
- Prefix variables with context when helpful: `vpc_cidr_block`, not just `cidr`.
- Give every variable and output a `description`.
- Give variables explicit `type` declarations.
- Mark secret variables and outputs as `sensitive = true`, but remember sensitive values may still exist in state.

## Resource Identity Rules

Prefer stable keys:

| Situation | Use | Why |
| --- | --- | --- |
| Optional singleton | `count = condition ? 1 : 0` | Simple create/don't create switch |
| Reorderable/removable collection | `for_each = toset(...)` or map | Stable addresses |
| Named resources | `for_each = var.items` | Reference by key |
| Long-lived objects | Map keys | Avoid list index churn |

Avoid using list indexes as long-lived resource identity. Removing a middle item can force replacements for later items.

When refactoring resource addresses, use `moved` blocks where supported:

```hcl
moved {
  from = aws_instance.old
  to   = aws_instance.web_server
}
```

## Version Guidance

Pin versions intentionally:

```hcl
terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

General rules:

- Runtime: pin minor version, e.g. `~> 1.9`.
- Providers: pin major version, e.g. `~> 5.0`.
- Production modules: pin exact release where practical.
- Commit `.terraform.lock.hcl` intentionally.
- Keep version upgrades in separate PRs from feature changes.

Feature floors to check before using modern syntax:

| Feature | Minimum Terraform version |
| --- | --- |
| `moved` blocks | 1.1 |
| Optional object attributes with defaults | 1.3 |
| `import` blocks | 1.5 |
| `check` blocks | 1.5 |
| Native `terraform test` | 1.6 |
| Mock providers in tests | 1.7 |
| `removed` blocks | 1.7 |
| Cross-variable validation | 1.9 |
| S3 native lockfile | 1.10 |
| Write-only arguments | 1.11 |

## State Management

Do not use local state for shared or production infrastructure.

Prefer remote backends with locking, encryption, versioning, and audit logs. For AWS S3 on Terraform 1.10+:

```hcl
terraform {
  backend "s3" {
    bucket       = "my-terraform-state"
    key          = "prod/networking/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

State split guidance:

- Split by environment: `dev`, `staging`, `prod`.
- Split by lifecycle/component: `networking`, `compute`, `data`.
- Split when teams, cadence, or blast radius differ.
- Combine only when resources are tightly coupled and small enough to reason about safely.

Before state migration or manual state operations:

1. Back up state.
2. Confirm backend lock behavior.
3. Run a plan before and after.
4. Prefer declarative `moved`, `import`, or `removed` blocks over imperative state edits.

## Security and Compliance

Baseline checks:

```bash
terraform fmt -check -recursive
terraform validate
trivy config .
checkov -d .
```

Do:

- Use dedicated VPCs and least-privilege network rules.
- Encrypt at rest and in transit.
- Use cloud secret managers instead of plaintext variables or tfvars.
- Keep credentials out of outputs and CI logs.
- Use standalone security group rule resources where the provider recommends them.
- Preserve plan, scan, and approval evidence for regulated environments.

Avoid:

- Secrets in defaults, `.tfvars`, committed files, logs, or outputs.
- Wide-open security groups such as `0.0.0.0/0` unless justified and controlled.
- Default VPC assumptions for production.
- Applying code that failed scans without documented exception approval.

## Testing Strategy

Choose test depth based on risk:

| Need | Approach |
| --- | --- |
| Basic syntax and formatting | `terraform fmt -check`, `terraform validate` |
| Static quality | `tflint`, `trivy`, `checkov` |
| Module logic on Terraform 1.6+ | Native `terraform test` |
| Cost-safe unit tests on Terraform 1.7+ | Native tests with mock providers |
| Complex real-cloud behavior | Terratest or controlled integration tests |
| Compliance gates | OPA/Conftest, Sentinel, Checkov policies |

Native test reminders:

- Use `command = plan` for input-derived values.
- Use `command = apply` for computed values such as ARNs, generated names, or provider-populated attributes.
- Do not index set-type nested blocks with `[0]`; use `for` expressions or apply-time assertions.

## CI/CD Standards

A safe pipeline should follow:

1. Format and validate
2. Static lint/security scan
3. Test
4. Plan and store plan artifact
5. Policy/approval gate
6. Apply the reviewed plan artifact

Important rules:

- CI and local versions should match.
- Do not re-run plan during apply and silently apply a different result.
- Protect production applies with approval.
- Run drift detection on a schedule for important environments.
- Use mocks or static checks for PRs when real-cloud tests are too expensive.

## Common Commands

Terraform:

```bash
terraform fmt -recursive
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform test
```

OpenTofu equivalents:

```bash
tofu fmt -recursive
tofu fmt -check -recursive
tofu init
tofu validate
tofu plan -out=tfplan
tofu show tfplan
tofu apply tfplan
tofu test
```

Security/linting:

```bash
tflint --init
tflint
trivy config .
checkov -d .
```

## Destructive Change Protocol

Before any destroy, replacement-heavy refactor, state removal, or import migration:

1. Identify all resources affected.
2. Generate and review the plan artifact.
3. Explain why deletion/replacement is expected.
4. Confirm backups and rollback path.
5. Get explicit approval before proceeding.

Never hide destructive changes inside a broad plan summary.

## Attribution

This project skill is adapted from ideas in `antonbabenko/terraform-skill` and simplified for this repository. Original project is Apache-2.0 licensed.
