# Exercises

These exercises turn the examples into practice. Try them after reading each level README.

The goal is not to finish quickly. The goal is to retrieve the idea from memory, make a small change, and check the result with `terraform plan`.

## Level 1: Foundation

1. Change the AWS region in the provider block.
2. Change the S3 bucket name prefix.
3. Run `terraform plan` and identify every resource Terraform wants to create.
4. Find one reference expression, such as `aws_s3_bucket.foundation.id`, and explain what it points to.

Check yourself:

- What does the provider block configure?
- What are the two labels in a resource block?

## Level 2: Abstraction

1. Copy the example variable file:

   ```bash
   cp dev.tfvars.example dev.tfvars
   ```

2. Add a new variable named `cost_center`.
3. Add `CostCenter = var.cost_center` to `local.common_tags`.
4. Add the value to `dev.tfvars`.
5. Run:

   ```bash
   terraform plan -var-file=dev.tfvars
   ```

Check yourself:

- Is `cost_center` an input, local, data source, or output?
- Why is `local.common_tags` better than repeating tags in every resource?

## Level 3: Structural

1. Add a new output inside `modules/static-site/outputs.tf` for the bucket ARN.
2. Expose that output from the root `outputs.tf`.
3. Run a plan with:

   ```bash
   terraform plan -var-file=dev.tfvars
   ```

Check yourself:

- What is the difference between the root module and child module?
- How does information cross a module boundary?

## Level 4: Dynamic

1. Add a third private subnet to `private_subnets`.
2. Add an SSH ingress rule for port `22`, but restrict it to a private CIDR range.
3. Set `enable_logs = false` and observe the plan.
4. Explain why the subnet resources use `for_each` instead of `count`.

Check yourself:

- What is `each.key`?
- What is `each.value`?
- What does the `dynamic "ingress"` block generate?

## Level 5: Ecosystem Integration

1. Select a workspace:

   ```bash
   terraform workspace new dev || terraform workspace select dev
   ```

2. Change `playbook.yml`.
3. Run `terraform plan` and observe whether the `null_resource` changes.
4. Generate a plan JSON and run the OPA command from the README.

Check yourself:

- What does `filesha256` detect?
- What do workspaces separate?
- Why are provisioners usually a last resort?

## Level 6: Operations Platform

1. Run:

   ```bash
   terraform init
   terraform test
   ```

2. Change `service_name` from `payments` to another value.
3. Update the test so it expects the new prefix.
4. Run `terraform test` again.

Check yourself:

- Why are outputs contracts?
- What does drift detection look for?
- Why should CI run `fmt`, `validate`, `test`, and `plan` before apply?

## Level 7: Real-world Project Layout

1. Compare `live/dev/network` and `live/prod/network`. What is the same, and what is different?
2. Change the dev VPC CIDR in `dev.tfvars.example`, then predict which stack should be affected.
3. Add a `region` variable to the network live stacks.
4. Explain why `modules/network` should not hardcode `dev` or `prod`.
5. Sketch where you would put a `database` stack in this layout.

Check yourself:

- What belongs in `modules/`?
- What belongs in `live/`?
- When should two parts of infrastructure have separate state files?

## Level 8: Enterprise Scale and Governance

1. Open `landing-zone/account-request.example.json`. Add a field that would help an auditor understand ownership.
2. Open `policy/required-tags.rego`. Explain what happens when a resource has no `tags` field at all.
3. Add one approved region to `policy/allowed-regions.rego`.
4. Add a new service entry to `catalog/service-catalog.example.yml` for a database pattern.
5. Open `dr/recovery-plan.example.md`. Write one check that proves the app is actually working after infrastructure is restored.

Check yourself:

- What problem does a landing zone solve?
- Why is a service catalog different from a module folder?
- Why is cost ownership part of infrastructure design?

## Stretch exercises

1. Add a root `Makefile` with commands such as `fmt`, `validate`, and `test`.
2. Extend the root `.gitignore` with one Terraform-generated artifact that is not already covered.
3. Add one more OPA policy rule.
4. Add a second environment tfvars example, such as `prod.tfvars.example`.
5. Write your own `09-*` level idea, but do not implement it until you can explain why the eight current levels are not enough.
