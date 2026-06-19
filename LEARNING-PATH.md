# Learning Path

Use this as the map for the book. Each level is meant to add one new layer, not replace the previous one.

| Level | Main question | Uses AWS? | What to inspect | Checkpoint |
|---|---|---:|---|---|
| 01 Foundation | What is the smallest useful Terraform program? | Yes | `main.tf` | Explain provider, resource, and hardcoded values |
| 02 Abstraction | How do I make code configurable? | Yes | `variables.tf`, `main.tf`, `outputs.tf` | Explain variables, locals, data sources, and outputs |
| 03 Structural | How do I package resources and manage state? | Yes | `modules/static-site/`, `backend.tf` | Explain modules, state, and remote backends |
| 04 Dynamic | How do I avoid copy-paste with logic? | Yes | `for_each`, `count`, `dynamic`, `lifecycle` in `main.tf` | Explain when to use `count` vs `for_each` |
| 05 Ecosystem Integration | How does Terraform connect to other tools? | No cloud resources by default | `main.tf`, `policy/`, `live/dev/` | Explain workspaces, provisioners, Terragrunt, and OPA |
| 06 Operations Platform | How do teams run Terraform safely? | No AWS | `ci/github-actions.yml`, `tests/` | Explain CI checks, tests, drift detection, and outputs as contracts |
| 07 Real-world Project Layout | Where does Terraform code go as repos grow? | No real cloud resources | `modules/`, `live/dev/`, `live/prod/` | Explain reusable modules, live stacks, and state boundaries |
| 08 Enterprise Scale and Governance | How do organizations govern Terraform across teams? | No | `policy/`, `catalog/`, `landing-zone/`, `finops/`, `dr/` | Explain landing zones, service catalogs, policy, cost, and recovery |

## Recommended pace

Do not rush the levels. For each one:

1. Read the level README.
2. Open the files it mentions.
3. Predict what `terraform plan` will show.
4. Run the command if the level has runnable Terraform.
5. Answer the checkpoint questions without looking.
6. Do the matching exercise in `EXERCISES.md`.

## If you are brand new

Start with:

```text
QUICKSTART.md
01-foundation/README.md
TERRAFORM-CLI.md
GLOSSARY.md
```

Do not worry about Level 8 yet. Governance will make more sense after you have seen modules, state, and CI.

## If you already know basic Terraform

Skim Levels 1 and 2, then spend more time on:

```text
03-structural
04-dynamic
07-real-world-project-layout
08-enterprise-scale-governance
```

Those levels cover the design decisions that tend to matter in real repositories.
