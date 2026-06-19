# Common Terraform Mistakes

This file collects the mistakes learners usually make while working through the levels.

## Level 1 — Foundation

### Forgetting `terraform init`

If Terraform says a provider is missing, run:

```bash
terraform init
```

### Confusing Terraform names with cloud names

In this block:

```hcl
resource "aws_s3_bucket" "foundation" {}
```

`foundation` is Terraform's local name. It is not automatically the S3 bucket name.

## Level 2 — Abstraction

### Using variables for internal values

Use variables for inputs. Use locals for internal expressions.

Good split:

```text
variable = caller chooses it
local    = module calculates it
```

### Forgetting to pass required variables

If a variable has no default, pass it with `-var`, `-var-file`, or a `.tfvars` file.

## Level 3 — Structural

### Thinking modules share state automatically

Modules organize code. State is still owned by the root module where Terraform runs.

### Enabling a remote backend before it exists

An S3 backend bucket and lock table must exist before Terraform can use them as a backend.

### Committing state

Do not commit `terraform.tfstate`. State can contain sensitive infrastructure data.

## Level 4 — Dynamic

### Using `count` for named things

If each resource has a meaningful name, prefer `for_each`.

```text
count    = simple number
for_each = stable key per item
```

### Forgetting that `prevent_destroy` blocks cleanup

`prevent_destroy = true` is useful, but `terraform destroy` may fail until you remove or comment it out.

## Level 5 — Ecosystem Integration

### Overusing provisioners

Provisioners are a last resort. Prefer images, cloud-init, configuration management, or deployment tools when possible.

### Treating workspaces as full environment isolation

Workspaces separate state. They do not automatically separate accounts, permissions, code, or blast radius.

### Expecting teaching policies to be production policies

The OPA examples are intentionally small. Real policy libraries need provider-specific edge-case handling and tests.

## Level 6 — Operations Platform

### Applying automatically without review

A CI pipeline should usually plan first, then require review or approval before apply.

### Changing outputs casually

Outputs are contracts. Scripts, CI jobs, or other modules may depend on their names and shapes.

## Level 7 — Real-world Project Layout

### Rebuilding one stack inside another stack

If `app` and `network` are separate live stacks, the app stack should consume network outputs, not recreate the network module inside its own state.

### Splitting state too much

Separate state by ownership, lifecycle, permissions, and blast radius. Do not create a separate state file for every tiny resource.

### Hiding environment boundaries

Reviewers should be able to see whether a change affects dev, prod, network, or app by looking at the path and backend key.

## Level 8 — Enterprise Scale and Governance

### Treating governance as paperwork

Good governance is code, defaults, feedback, and audit trails. If it is only a document, teams will bypass it.

### Making golden paths harder than custom work

A golden path should be the easiest safe option. If it is painful, teams will invent their own path.

### Thinking Terraform equals disaster recovery

Terraform can recreate infrastructure shape. Recovery also needs data backups, restore tests, failover steps, and runbooks.

## General mistakes

### Running apply before reading the plan

Always read the plan. Pay attention to destroys, replacements, public access, IAM, and storage changes.

### Committing secrets

Do not commit credentials, private keys, real `.tfvars` files with secrets, or state files.

### Adding tools too early

Learn Terraform's core loop first:

```text
init -> validate -> plan -> apply
```

Then add Terragrunt, OPA, Packer, Argo CD, Flux, or CI tools when you understand the problem they solve.
