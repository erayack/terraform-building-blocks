# Quickstart

Use this page when you want to run the first example now and read the longer chapters afterward.

## 1. Check your tools

Required:

```bash
terraform version
aws --version
```

Useful later:

```bash
opa version
terragrunt --version
```

## 2. Check AWS access

The AWS examples use your normal AWS credentials.

```bash
aws configure
aws sts get-caller-identity
```

If `aws sts get-caller-identity` returns your account, Terraform can usually authenticate too.

## 3. Run Level 1

```bash
cd 01-foundation
terraform init
terraform fmt
terraform validate
terraform plan
```

If the plan looks right and you are comfortable creating the resources, apply it:

```bash
terraform apply
```

When you are done, clean up:

```bash
terraform destroy
```

## 4. Continue in order

```text
01-foundation
02-abstraction
03-structural
04-dynamic
05-ecosystem-integration
06-operations-platform
07-real-world-project-layout
08-enterprise-scale-governance
```

Each directory is its own Terraform example. Run Terraform commands from inside the directory you are studying.

## 5. Use the example tfvars files

Some levels need variables. Copy the example file first:

```bash
cp dev.tfvars.example dev.tfvars
```

Then plan with it:

```bash
terraform plan -var-file=dev.tfvars
```

Real `.tfvars` files are ignored by Git in this repo. The `*.tfvars.example` files are safe templates.

## 6. Try the local-only level

`06-operations-platform` uses the `random` provider, so it does not need AWS.

```bash
cd 06-operations-platform
terraform init
terraform validate
terraform test
terraform plan
```

## 7. Keep these nearby

- [`README.md`](README.md): map of the repo
- [`TERRAFORM-CLI.md`](TERRAFORM-CLI.md): command guide
- [`GLOSSARY.md`](GLOSSARY.md): Terraform vocabulary
- [`COST-SAFETY.md`](COST-SAFETY.md): cost and cleanup notes
