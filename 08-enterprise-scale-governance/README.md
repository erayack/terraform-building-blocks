# Level 8: Enterprise Scale and Governance

Level 7 showed where Terraform code goes when a repo grows. Level 8 looks at what happens when Terraform is used across many teams, accounts, regions, and compliance requirements.

The question changes again:

> How do we let teams move quickly without letting every team invent its own infrastructure rules?

This level is about governance. Not governance as paperwork, but governance as reusable code, safe defaults, visible ownership, and reviewable exceptions.

## The problem

Terraform gets harder when an organization has:

- many AWS accounts or cloud projects,
- many application teams,
- shared networking and identity,
- audit requirements,
- cost controls,
- production change approvals,
- disaster recovery expectations.

At that point, a good module is not enough. You need a system around Terraform.

## Enterprise building blocks

This level uses small examples for five areas:

```text
08-enterprise-scale-governance/
├── landing-zone/
│   └── account-request.example.json
├── policy/
│   ├── required-tags.rego
│   ├── allowed-regions.rego
│   └── fixtures/
│       ├── missing-tags.plan.json
│       ├── complete-tags.plan.json
│       └── disallowed-region.plan.json
├── catalog/
│   └── service-catalog.example.yml
├── finops/
│   └── budget-policy.example.yml
├── dr/
│   └── recovery-plan.example.md
└── README.md
```

These are not complete production systems. They are teaching artifacts that show the shape of enterprise Terraform governance.

## Landing zones

A landing zone is the prepared foundation where teams deploy infrastructure.

It usually includes:

- accounts or subscriptions,
- identity and access boundaries,
- networking baselines,
- logging and audit trails,
- security guardrails,
- remote state locations,
- standard tags and naming rules.

Terraform often manages landing zone pieces, but organizations usually treat landing zones as a platform capability, not as app-team code.

Example account request:

```json
{
  "team": "payments",
  "environment": "prod",
  "cloud": "aws",
  "region": "us-east-1",
  "cost_center": "fin-2042",
  "data_classification": "confidential"
}
```

The request is small. The platform behind it may create an account, attach policies, configure logging, and prepare a Terraform backend.

## Multi-account strategy

One AWS account for everything is simple until it is not.

Common account boundaries:

```text
shared-services
network
security
logging
dev
test
prod
sandbox
```

Why split accounts:

- smaller blast radius,
- clearer billing,
- stronger permission boundaries,
- easier audit trails,
- safer experiments.

Terraform can work across accounts using provider aliases and assumed roles. The important design rule is simple:

> Make account boundaries obvious in code review.

If a plan affects prod, reviewers should not have to guess.

## Multi-cloud strategy

Terraform can talk to many providers in one configuration. That does not mean every module should be multi-cloud.

A useful split:

```text
cloud-specific modules for implementation
cloud-neutral interfaces for platform consumers
```

For example, a service catalog might let a team request:

```text
object storage, encrypted, private, tagged
```

The AWS implementation might create S3. The Azure implementation might create Storage Account resources. The consumer should not need to know every provider detail unless the abstraction leaks.

Do not force multi-cloud abstractions too early. They are expensive to maintain.

## Policy as code at scale

In Level 5, you saw one OPA policy. At enterprise scale, policies become a library.

Common policies:

- required tags,
- allowed regions,
- encryption required,
- no public storage,
- no overly permissive IAM,
- approved instance families,
- production changes require review.

The goal is not to block everyone. The goal is to catch predictable mistakes before apply.

Good policy messages should tell the user:

1. what failed,
2. why it failed,
3. how to fix it,
4. how to request an exception if one exists.

## Service catalog and golden paths

A service catalog gives teams approved ways to create common infrastructure.

Examples:

```text
static site
private service
postgres database
queue
cache
kubernetes namespace
```

A golden path is the recommended route. It should be easier than building from scratch.

Good golden paths include:

- approved modules,
- safe defaults,
- required tags,
- monitoring hooks,
- cost expectations,
- ownership metadata,
- documentation.

If the golden path is painful, teams will work around it.

## Self-service with guardrails

Self-service does not mean everyone can create anything.

A healthier model:

```text
teams choose from approved patterns
platform supplies modules and policy
CI/CD checks the plan
audit trails record who changed what
exceptions are explicit
```

Terraform is often the engine behind this, but the user interface may be a portal, a pull request, a Backstage template, or an internal CLI.

## Cost governance

Cost controls should happen before the bill arrives.

Common FinOps checks:

- estimate cost from plans,
- enforce budgets,
- require cost center tags,
- flag oversized resources,
- track owner and environment,
- report showback or chargeback.

A useful review question:

> If this plan is applied, who pays for it and who owns it?

If the answer is unclear, the code needs better metadata.

## Audit and evidence

Auditors usually care about evidence:

- who changed infrastructure,
- when it changed,
- what was approved,
- which policy checks ran,
- whether production changes followed the process,
- whether logs and encryption were enabled.

Terraform helps because plans, commits, CI runs, and state history can be tied together.

Do not rely on memory or screenshots. Automate evidence where possible.

## Disaster recovery and resilience

Terraform can help rebuild infrastructure, but Terraform alone is not a disaster recovery plan.

You also need:

- backups,
- restore tests,
- replicated data,
- DNS or traffic failover,
- runbooks,
- recovery time objectives,
- recovery point objectives.

Terraform answers:

> Can we recreate the infrastructure shape?

DR planning asks:

> Can the business recover the service in time, with acceptable data loss?

Those are related, but not the same.

## GitOps boundary

Argo CD and Flux belong in the enterprise conversation, but they usually manage Kubernetes application state, not cloud foundation resources.

A common boundary:

```text
Terraform creates cloud infrastructure and Kubernetes clusters
Argo CD or Flux reconciles applications inside those clusters
```

There are exceptions, but this boundary keeps ownership clearer.

## What to inspect

Open these files:

```text
landing-zone/account-request.example.json
policy/required-tags.rego
policy/allowed-regions.rego
policy/fixtures/missing-tags.plan.json
policy/fixtures/complete-tags.plan.json
policy/fixtures/disallowed-region.plan.json
catalog/service-catalog.example.yml
finops/budget-policy.example.yml
dr/recovery-plan.example.md
```

They show the pieces around Terraform rather than more Terraform syntax. That is intentional. Enterprise scale is mostly about boundaries, rules, ownership, and feedback loops.

## Commands

If you have OPA installed, you can inspect the policy files:

```bash
opa fmt policy/*.rego
```

Level 8 does not contain Terraform infrastructure to plan. To evaluate a policy, generate a plan JSON from an earlier level, then run OPA from this directory:

```bash
cd ../02-abstraction
cp dev.tfvars.example dev.tfvars
terraform init
terraform plan -out=plan.out -var-file=dev.tfvars
terraform show -json plan.out > ../08-enterprise-scale-governance/plan.json

cd ../08-enterprise-scale-governance
opa eval --input plan.json --data policy/required-tags.rego 'data.terraform.policy.deny'
```

This Level 2 example is expected to return a denial because its bucket tags do not include the enterprise `Owner` and `CostCenter` tags required by `required-tags.rego`. That is the governance lesson: a syntactically valid Terraform plan can still fail an organizational policy check.

You can also try the tiny fixtures without running Terraform:

```bash
opa eval --input policy/fixtures/missing-tags.plan.json --data policy/required-tags.rego 'data.terraform.policy.deny'
opa eval --input policy/fixtures/complete-tags.plan.json --data policy/required-tags.rego 'data.terraform.policy.deny'
opa eval --input policy/fixtures/disallowed-region.plan.json --data policy/allowed-regions.rego 'data.terraform.policy.deny'
```

The example policies are intentionally narrow:

- `required-tags.rego` checks resources that expose a `tags` attribute in the plan.
- `allowed-regions.rego` checks the `aws_region` Terraform variable when that variable exists in the plan JSON.

Production policies usually need more context from provider configuration, CI metadata, account inventory, or platform APIs.

The example catalog, budget, and recovery files are source material. They are meant to be read, adapted, and turned into real platform workflows later.

## Checkpoint

Before moving on, answer these from memory:

1. What problem does a landing zone solve?
2. Why do organizations split infrastructure across accounts or projects?
3. What makes a policy message useful?
4. What is the difference between a service catalog and a Terraform module?
5. Why is cost ownership part of infrastructure design?
6. Why is Terraform not a complete disaster recovery plan by itself?
