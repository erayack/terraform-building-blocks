# Level 7: Real-world Project Layout

By now you have seen Terraform's main building blocks. This level is about where those blocks go when a repo grows past a few files.

The question changes from:

> How do I write this resource?

To:

> Where should this code live, who owns it, and how will dev, staging, and prod use it safely?

This level is mostly structure and judgment. There is very little new Terraform syntax.

## The problem

Small Terraform examples often look like this:

```text
main.tf
variables.tf
outputs.tf
```

That is fine for learning. It breaks down when you have:

- multiple environments,
- shared modules,
- separate teams,
- different AWS accounts or regions,
- different release speeds,
- state files with different blast radius.

A real repository needs boundaries.

## Example layout

```text
07-real-world-project-layout/
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── app/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── live/
    ├── dev/
    │   ├── network/
    │   │   ├── backend.tf
    │   │   ├── main.tf
    │   │   └── dev.tfvars.example
    │   └── app/
    │       ├── backend.tf
    │       ├── main.tf
    │       └── dev.tfvars.example
    └── prod/
        ├── network/
        │   ├── backend.tf
        │   ├── main.tf
        │   └── prod.tfvars.example
        └── app/
            ├── backend.tf
            ├── main.tf
            └── prod.tfvars.example
```

There are two big areas:

- `modules/`: reusable building blocks.
- `live/`: real environment stacks that call those modules.

## `modules/` vs `live/`

A reusable module should not know whether it is being used by dev or prod.

For example, a network module should expose inputs like:

```hcl
variable "vpc_cidr" {
  type = string
}
```

The live environment decides the actual value:

```hcl
vpc_cidr = "10.10.0.0/16"
```

Think of it this way:

```text
modules/ = how to build a thing
live/    = what we actually run in an environment
```

## Root modules as stacks

Each folder under `live/` is a root module, sometimes called a stack.

Examples:

```text
live/dev/network
live/dev/app
live/prod/network
live/prod/app
```

Each stack has its own state. That is intentional.

The network stack can change without putting the app stack's entire state at risk. The app stack can deploy more often without touching VPC resources.

## When to split state

Split state when resources have different:

- owners,
- lifecycles,
- blast radius,
- permissions,
- apply frequency.

Good split:

```text
network state
app state
database state
observability state
```

Risky split:

```text
every single resource gets its own state
```

Too many states create coordination pain. Too few states create large blast radius.

## Environment folders vs workspaces

Earlier, you saw workspaces. Workspaces are useful, but many real repos prefer folders for environments:

```text
live/dev
live/prod
```

Why folders are often clearer:

- code review shows exactly which environment changed,
- backend keys are explicit,
- environment-specific inputs are visible,
- permissions can be separated more easily,
- CI can target one folder at a time.

Workspaces are not bad. They are just not always the clearest boundary for serious environments.

## Backend key strategy

Each live stack should have a separate backend key.

Example:

```hcl
backend "s3" {
  bucket         = "my-company-terraform-state"
  key            = "dev/network/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

For prod app:

```hcl
key = "prod/app/terraform.tfstate"
```

The key should tell you what state file you are looking at without opening Terraform.

## Module versioning

In this teaching repo, live stacks call local modules:

```hcl
module "network" {
  source = "../../../modules/network"
}
```

In a larger organization, modules are often versioned:

```hcl
module "network" {
  source  = "git::https://github.com/example/terraform-modules.git//network?ref=v1.2.0"
}
```

Versioning lets dev test a new module version before prod uses it.

## Dependency boundaries

Stacks often depend on outputs from other stacks.

Example:

```text
app needs network_name and subnet_ids from network
```

In this level, the app stack accepts those values as variables:

```hcl
variable "network_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
```

That keeps `live/dev/network` and `live/dev/app` as separate root modules with separate state files. The app stack does not recreate the network module inside its own state.

There are a few common ways to pass those values in real projects:

1. Use `terraform_remote_state`.
2. Publish outputs to a parameter store.
3. Pass values through CI/CD.
4. Use an orchestrator such as Terragrunt or Terramate.

For learning, the important point is this:

> Dependencies between stacks should be explicit.

Hidden dependencies make applies surprising.

## Provider aliases

Real projects may need more than one provider configuration.

Example use cases:

- deploy to two AWS regions,
- read shared networking from one account and create app resources in another,
- manage DNS in a central account.

Terraform supports provider aliases:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

A resource can choose the alias:

```hcl
resource "aws_s3_bucket" "west" {
  provider = aws.west
  bucket   = "example-west-bucket"
}
```

Do not introduce aliases until you need them. They are useful, but they add wiring.

## Naming conventions

Pick boring names and use them everywhere.

Useful naming parts:

```text
project
environment
region
component
```

Example:

```text
payments-prod-us-east-1-app
```

The exact convention matters less than consistency.

## What belongs in this level's code?

The code in this folder is intentionally skeletal. It shows the shape of a repo, not a complete AWS deployment.

That is the lesson: layout is a design tool.

A good layout tells future readers:

- what is reusable,
- what is live,
- what environment is affected,
- where state belongs,
- which team probably owns the code.

## What to inspect

Open these files side by side:

```text
modules/network/variables.tf
modules/app/variables.tf
live/dev/network/main.tf
live/dev/app/main.tf
```

Notice the split:

- modules define reusable behavior,
- live stacks choose values,
- app receives network information as input instead of rebuilding the network stack.

That is the layout lesson in code form.

## Commands

You normally run Terraform from a live stack:

```bash
cd live/dev/network
cp dev.tfvars.example dev.tfvars
terraform init
terraform validate
terraform plan -var-file=dev.tfvars
```

Then another stack:

```bash
cd ../app
cp dev.tfvars.example dev.tfvars
terraform init
terraform validate
terraform plan -var-file=dev.tfvars
```

## Checkpoint

Before moving on, answer these from memory:

1. What is the difference between `modules/` and `live/`?
2. Why might `network` and `app` use separate state files?
3. Why are environment folders often clearer than workspaces for larger repos?
4. What makes a backend key easy to understand?
5. When would provider aliases be useful?
