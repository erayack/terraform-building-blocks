# Tools Commonly Used with Terraform

Terraform rarely works alone. In real projects it usually sits next to cloud CLIs, Git, CI, security checks, image builders, Kubernetes tools, and monitoring systems.

You do not need all of these on day one. Learn Terraform's own loop first:

```text
init -> validate -> plan -> apply
```

Then add other tools when you can name the problem they solve.

## Cloud CLIs

Examples:

- AWS CLI: `aws`
- Azure CLI: `az`
- Google Cloud CLI: `gcloud`

You will use these for login, account checks, quick debugging, and sometimes for bootstrapping remote state before Terraform can manage it.

Example:

```bash
aws sts get-caller-identity
```

## Git and code review

Examples:

- Git
- GitHub
- GitLab
- Bitbucket

Terraform code should be reviewed like application code. A pull request gives the team a place to discuss the plan, naming, cost, security, and blast radius before anything changes.

## CI/CD systems

Examples:

- GitHub Actions
- GitLab CI
- CircleCI
- Jenkins
- Buildkite
- Spacelift
- Atlantis
- Terraform Cloud / HCP Terraform

CI usually runs the boring checks every time:

```bash
terraform fmt -check
terraform validate
terraform test
terraform plan
```

A more mature pipeline also handles approvals, applies, drift checks, and notifications.

## Policy as code

Examples:

- OPA / Conftest
- Sentinel
- Checkov
- tfsec
- Terrascan

Policy tools answer questions like:

- Are buckets encrypted?
- Is public access blocked?
- Are required tags present?
- Is this region allowed?
- Is this instance size too large?

Terraform tells you what will change. Policy tools decide whether that change is allowed.

## Secret management

Examples:

- AWS Secrets Manager
- AWS SSM Parameter Store
- HashiCorp Vault
- Azure Key Vault
- Google Secret Manager
- Doppler
- 1Password Secrets Automation
- Infisical
- OpenBao

Do not hardcode secrets in `.tf` or `.tfvars` files. Store secrets in a secret manager and pass references around when possible.

## Machine image building

Examples:

- Packer
- AWS EC2 Image Builder
- Azure VM Image Builder
- Google Cloud image tooling

Packer builds machine images. Terraform deploys those images.

Common AWS flow:

```text
Packer builds an AMI
Terraform uses that AMI in an EC2 instance, launch template, or autoscaling group
```

Packer answers:

> What should be inside the machine image?

Terraform answers:

> Where should that image run, and with what networking, IAM, scaling, and security settings?

This is often cleaner than using Terraform provisioners to install a large amount of software during instance creation.

## Configuration management

Examples:

- Ansible
- Chef
- Puppet
- Salt
- cloud-init

Terraform is strongest at provisioning infrastructure. Configuration management tools are better at configuring operating systems and applications.

A common split:

```text
Terraform creates the VM
Packer bakes most packages into the image
cloud-init or Ansible handles small environment-specific setup
```

## Containers, Kubernetes, and GitOps

Examples:

- Docker
- Kubernetes
- Helm
- Kustomize
- kubectl
- Argo CD
- Flux CD

Terraform can create a Kubernetes cluster and the cloud resources around it. Many teams then hand application deployment to Kubernetes-native tools.

Common split:

```text
Terraform creates the cluster and cloud dependencies
Argo CD or Flux deploys applications into the cluster from Git
```

Argo CD and Flux are GitOps controllers. They watch Git repositories and keep Kubernetes resources in sync with what is stored there.

## Cost estimation

Examples:

- Infracost
- cloud provider cost explorers

Cost tools help reviewers see the price impact before apply.

Typical flow:

```text
terraform plan -> cost estimate -> review -> apply
```

## Documentation and diagrams

Examples:

- terraform-docs
- Rover
- Blast Radius
- Graphviz

These tools help explain modules and dependency graphs. Terraform also has a built-in graph command:

```bash
terraform graph
```

## OpenTofu

OpenTofu is an open-source fork of Terraform created after Terraform's license changed from MPL to BUSL. It uses the same basic workflow and much of the same language style:

```bash
tofu init
tofu plan
tofu apply
```

For many learning examples, Terraform and OpenTofu look almost identical. In real projects, check provider compatibility, backend behavior, and team/tooling support before switching.

## Wrappers and orchestrators

Examples:

- Terragrunt
- Terramate
- Atmos

These tools help when you have many modules, regions, accounts, or environments. They reduce repetition around backend config, shared inputs, and stack orchestration.

Use them when the directory structure starts fighting you. Do not add one just because it is popular.

## Testing tools

Examples:

- Terraform native tests: `terraform test`
- Terratest
- Kitchen-Terraform

Tests can check module contracts, validation rules, outputs, and real infrastructure behavior. Native Terraform tests are a good starting point. Terratest is useful when you need deeper integration tests in Go.

## Observability and operations

Examples:

- CloudWatch
- Datadog
- Prometheus
- Grafana
- OpenTelemetry

Terraform can create dashboards, alerts, and monitors. These tools tell you what happens after the infrastructure exists.

## Common toolchains

Beginner:

```text
Terraform + cloud CLI + Git
```

Team workflow:

```text
Terraform + Git + CI/CD + remote state + policy checks
```

Platform workflow:

```text
Terraform + Packer + CI/CD + Terragrunt/Terramate + OPA/Sentinel + Infracost + Vault + observability
```
