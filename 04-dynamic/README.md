# Level 4 — The Dynamic

Level 4 replaces repeated copy/paste configuration with Terraform expressions and meta-arguments.

The goal is not to make code clever. The goal is to describe patterns:

- one subnet per item in a map,
- one log group only if logging is enabled,
- one ingress rule per object in a list,
- safe replacement behavior for resources.

## Files in this level

```text
main.tf
variables.tf
outputs.tf
README.md
```

This level creates a VPC, private subnets, a security group, and an optional CloudWatch log group.

## Meta-argument: `for_each`

```hcl
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}
```

`for_each` creates one resource instance per item in a map or set.

Given this variable:

```hcl
private_subnets = {
  private-a = { cidr = "10.40.1.0/24", az = "us-east-1a" }
  private-b = { cidr = "10.40.2.0/24", az = "us-east-1b" }
}
```

Terraform creates:

```text
aws_subnet.private["private-a"]
aws_subnet.private["private-b"]
```

Inside the resource:

```hcl
each.key
```

is the map key, such as `private-a`.

```hcl
each.value
```

is the map value, such as:

```hcl
{ cidr = "10.40.1.0/24", az = "us-east-1a" }
```

Use `for_each` when each instance has a stable identity.

## Meta-argument: `count`

```hcl
resource "aws_cloudwatch_log_group" "app" {
  count = var.enable_logs ? 1 : 0
}
```

`count` creates a numbered list of resource instances.

Here it is used as an on/off switch:

```hcl
var.enable_logs ? 1 : 0
```

This is a conditional expression:

```hcl
condition ? value_if_true : value_if_false
```

If `enable_logs` is true, Terraform creates one log group. If false, Terraform creates none.

Use `count` for simple quantities. Prefer `for_each` when resources need stable names.

## Dynamic nested blocks

Some resources contain nested blocks. A security group can contain many `ingress` blocks:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules

  content {
    description = ingress.value.description
    from_port   = ingress.value.port
    to_port     = ingress.value.port
    protocol    = "tcp"
    cidr_blocks = ingress.value.cidr_blocks
  }
}
```

A `dynamic` block generates repeated nested blocks.

Syntax:

```hcl
dynamic "BLOCK_NAME" {
  for_each = COLLECTION

  content {
    argument = BLOCK_NAME.value.field
  }
}
```

In this example, the dynamic block is named `ingress`, so each item is available as:

```hcl
ingress.value
```

This avoids manually writing many nearly identical ingress blocks.

## Object types

The input variable uses a rich type:

```hcl
variable "ingress_rules" {
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
}
```

This says `ingress_rules` must be a list, and every item in the list must be an object with exactly these fields.

Typed structures make dynamic Terraform safer. Without types, errors move later into planning or provider calls.

## Lifecycle rules

```hcl
lifecycle {
  create_before_destroy = true
}
```

The `lifecycle` block changes how Terraform manages a resource.

`create_before_destroy` tells Terraform:

> If replacement is required, create the new object before destroying the old object.

This can reduce downtime for replaceable resources.

Another example:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This prevents accidental deletion. In this level it protects the log group.

Important: `prevent_destroy` is a learning safety rail, but it can also block legitimate cleanup. If you run `terraform destroy`, Terraform may refuse until you remove it.

In this level, that behavior is intentional. The log group resource includes `prevent_destroy = true` so you can see how Terraform protects a resource from deletion. If you apply this level and later want to clean up everything, remove or comment out the `prevent_destroy` lifecycle block first, then run `terraform destroy` again.

## For expressions in outputs

```hcl
output "private_subnet_ids" {
  value = { for name, subnet in aws_subnet.private : name => subnet.id }
}
```

This transforms one map into another map.

It reads as:

> For each subnet instance, return a map from subnet name to subnet ID.

General syntax:

```hcl
{ for key, value in collection : new_key => new_value }
```

## Choosing between `count`, `for_each`, and `dynamic`

| Tool | Use when |
|---|---|
| `count` | You need N similar resources or a simple on/off switch |
| `for_each` | Each resource needs a stable key/name |
| `dynamic` | You need repeated nested blocks inside one resource |

## Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

Try changing:

```hcl
enable_logs = false
```

or add another subnet/rule in `variables.tf`, then run another plan.

## What you should understand before moving on

You should be able to explain:

1. Why `for_each` gives stable resource addresses.
2. Why `count` is useful for optional resources.
3. What a dynamic block generates.
4. How object types protect complex inputs.
5. How lifecycle rules change Terraform behavior.
