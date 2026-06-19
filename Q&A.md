# Terraform Q&A

Short questions and answers to reinforce the ideas in this repository.

## General

### What is Terraform?

Terraform is a desired-state infrastructure tool. You describe what infrastructure should exist, and Terraform plans/applies changes to make reality match that description.

### Is Terraform a programming language?

Terraform uses HCL, a configuration language. It has expressions, functions, variables, and loops-like constructs, but its main purpose is declaring infrastructure, not writing general-purpose programs.

### What is the safest Terraform habit?

Run and read a plan before applying:

```bash
terraform plan
```

For extra safety, save the reviewed plan:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## Providers and Resources

### What does a provider do?

A provider is a plugin that translates Terraform configuration into API calls for a platform such as AWS, Azure, Google Cloud, Kubernetes, or GitHub.

### What is a resource?

A resource is one managed infrastructure object, such as an S3 bucket, VPC, subnet, instance, or security group.

### What do the two labels in a resource mean?

In this block:

```hcl
resource "aws_s3_bucket" "example" {}
```

- `aws_s3_bucket` is the provider resource type.
- `example` is Terraform's local name for that resource.

Terraform references it as:

```hcl
aws_s3_bucket.example
```

## Variables, Locals, Data, Outputs

### When should I use a variable?

Use a variable when a value should be provided by the caller, environment, CLI, or tfvars file.

### When should I use a local?

Use a local when a value is internal to the module and helps reduce repetition or clarify a complex expression.

### What is the difference between a resource and a data source?

A resource creates or manages something. A data source reads existing information.

### What are outputs for?

Outputs expose useful values from a module, such as bucket names, subnet IDs, URLs, or generated release names.

## Modules and State

### What is a module?

A module is a directory of Terraform code. The directory where you run Terraform is the root module. A module called by another module is a child module.

### Why does Terraform need state?

State maps Terraform resources to real-world objects. Without state, Terraform would not know what it already created or what needs to change.

### Should I edit `terraform.tfstate` manually?

No. Treat state as Terraform-managed data. Use Terraform commands for state operations.

### Why use a remote backend?

A remote backend lets teams share state safely, usually with locking, encryption, and backup support.

## Dynamic Terraform

### Should I use `count` or `for_each`?

Use `count` for simple quantities or on/off resources. Use `for_each` when each instance has a meaningful stable key.

### What does a dynamic block do?

A dynamic block generates repeated nested blocks inside a resource, such as many `ingress` rules inside one security group.

### What does `lifecycle` do?

`lifecycle` changes Terraform's behavior for a resource, such as creating a replacement before destroying the old resource or preventing accidental destruction.

## CLI

### What is the difference between `validate`, `plan`, and `apply`?

- `validate` checks Terraform syntax and configuration consistency.
- `plan` previews changes.
- `apply` makes real changes.

### What does `terraform init` do?

It prepares the working directory by downloading providers, installing modules, and configuring the backend.

### What does `terraform destroy` do?

It destroys resources managed by the current Terraform state.

### What does `terraform output -json` do?

It prints outputs in machine-readable JSON so scripts and CI systems can consume them.

## Safety

### Can these examples cost money?

Yes. Levels 1–4 can create AWS resources. Read `COST-SAFETY.md` before applying and run `terraform destroy` when finished.

### Should I commit `.tfvars` files?

Usually no. They can contain account-specific values or secrets. This repo commits only `*.tfvars.example` files.

### Should I commit Terraform state?

No. State can contain sensitive infrastructure data. Use a backend for real teamwork.

## Ecosystem

### What are workspaces?

Workspaces are separate state instances for the same Terraform configuration. They change state, not code.

### What is Terragrunt?

Terragrunt is a wrapper around Terraform often used to manage repeated multi-environment or multi-account patterns.

### What is policy as code?

Policy as code means writing rules that check infrastructure changes before they are applied.

### Does the GitHub Actions YAML create infrastructure?

No. In this repo it is stored under `06-operations-platform/ci/` as educational source material. It does not run automatically unless copied into `.github/workflows/`.

## Real-world Layout

### What belongs in `modules/`?

Reusable Terraform building blocks belong in `modules/`. They should describe how to build something without hardcoding a specific environment.

### What belongs in `live/`?

Real environment stacks belong in `live/`. These are the root modules you run Terraform from for dev, prod, network, app, and similar boundaries.

### Why split state between stacks?

Split state when parts of the system have different owners, lifecycles, permissions, apply frequency, or blast radius.

### Are folders better than workspaces?

Not always, but folders are often clearer for serious environments because code review, backend keys, permissions, and CI targeting are more explicit.

## Enterprise Scale and Governance

### What is a landing zone?

A landing zone is a prepared cloud foundation for teams. It usually includes accounts or projects, identity boundaries, networking, logging, security guardrails, and state storage patterns.

### What is a service catalog?

A service catalog is a set of approved infrastructure patterns teams can request or reuse. It may use Terraform modules underneath, but it adds ownership, guardrails, documentation, and workflow around them.

### Why does policy as code matter at scale?

Policy as code catches repeated mistakes before apply. It gives teams fast feedback and gives the organization a consistent way to enforce rules.

### What is FinOps in a Terraform workflow?

FinOps connects infrastructure changes to cost ownership. In Terraform workflows, that usually means cost estimation, budget checks, required tags, and showback or chargeback reporting.

### Why is Terraform not a full disaster recovery plan?

Terraform can recreate infrastructure shape, but recovery also needs data backups, restore tests, failover steps, runbooks, and business recovery targets.

## Final Check

If you can answer these from memory, you understand the core of this repo:

1. What is the provider/resource relationship?
2. Why does Terraform need state?
3. What problem do variables and locals solve differently?
4. Why are modules useful?
5. When would you use `for_each` instead of `count`?
6. Why should a team review plans before applying?
