# Terraform Building Blocks: 6 Levels

A small, book-style Terraform course you can run locally. It starts with one hardcoded resource and builds up to modules, dynamic configuration, policy checks, and platform workflows.

The examples use AWS so the code feels real. The same Terraform ideas apply to Azure, Google Cloud, Kubernetes, GitHub, and most other providers.

> Safety: some examples can create billable AWS resources. Read [`COST-SAFETY.md`](COST-SAFETY.md), check every plan, and destroy anything you create for practice.

## Levels

1. [Foundation](01-foundation/README.md): providers, resources, hardcoded values
2. [Abstraction](02-abstraction/README.md): variables, outputs, data sources, locals
3. [Structural](03-structural/README.md): modules, state, remote backend
4. [Dynamic](04-dynamic/README.md): `count`, `for_each`, dynamic blocks, lifecycle
5. [Ecosystem Integration](05-ecosystem-integration/README.md): provisioners, workspaces, Terragrunt, policy as code
6. [Operations Platform](06-operations-platform/README.md): CI/CD, testing, drift detection, promotion, observability

## How to study this repo

Treat this as a short technical book with runnable code. Each level gives you the idea, the syntax, a working example, commands to try, and a few questions to check whether it stuck.

Suggested path:

1. [`QUICKSTART.md`](QUICKSTART.md): run the first example with minimal reading.
2. [`COST-SAFETY.md`](COST-SAFETY.md): know what can create AWS resources and how to clean up.
3. Level READMEs: read them in order from `01-foundation` to `06-operations-platform`.
4. [`TERRAFORM-CLI.md`](TERRAFORM-CLI.md): keep this open when you forget a command.
5. [`GLOSSARY.md`](GLOSSARY.md): use this when Terraform vocabulary starts to blur together.
6. [`EXERCISES.md`](EXERCISES.md): do the small changes after each level.
7. [`Q&A.md`](Q&A.md): quiz yourself without digging through the chapters.
8. [`TOOLS-AROUND-TERRAFORM.md`](TOOLS-AROUND-TERRAFORM.md): see what usually surrounds Terraform in real teams.

## Suggested workflow

```bash
cd 01-foundation
terraform init
terraform fmt
terraform validate
terraform plan
```

Only run `terraform apply` when the plan makes sense to you.

## Prerequisites

- Terraform >= 1.6
- AWS CLI configured with credentials
- An AWS account with permission to create the resources shown in the examples

## Repository layout

```text
.
├── 01-foundation/
│   ├── main.tf
│   └── README.md
├── 02-abstraction/
│   ├── dev.tfvars.example
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── README.md
├── 03-structural/
│   ├── modules/static-site/
│   ├── backend.tf
│   ├── dev.tfvars.example
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── README.md
├── 04-dynamic/
│   ├── dev.tfvars.example
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── README.md
├── 05-ecosystem-integration/
│   ├── live/dev/terragrunt.hcl
│   ├── policy/s3-encryption.rego
│   ├── main.tf
│   ├── playbook.yml
│   └── README.md
├── 06-operations-platform/
│   ├── ci/github-actions.yml
│   ├── tests/release.tftest.hcl
│   ├── main.tf
│   └── README.md
├── QUICKSTART.md
├── TERRAFORM-CLI.md
├── GLOSSARY.md
├── COST-SAFETY.md
├── EXERCISES.md
├── Q&A.md
├── TOOLS-AROUND-TERRAFORM.md
└── README.md
```
