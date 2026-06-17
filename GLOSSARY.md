# Terraform Building Blocks Glossary

A compact reference for the language used across the six Terraform levels. These definitions are intentionally short so they can be reviewed quickly while working through the examples.

## Core Terraform Terms

**Provider**: A Terraform plugin that translates Terraform configuration into API calls for a platform such as AWS, Azure, Google Cloud, or Kubernetes.

**Resource**: A managed infrastructure object declared in Terraform, such as an S3 bucket, VPC, instance, or security group.

**State**: Terraform's record of the resources it manages and the real-world objects they map to.

**Plan**: Terraform's proposed set of changes after comparing configuration, state, and real infrastructure.

**Apply**: The operation that executes a Terraform plan and changes real infrastructure.

## Configuration Building Blocks

**Variable**: An input value for a Terraform module.

**Local**: An internal named expression used to reduce repetition or clarify intent.

**Data source**: A read-only lookup of information from a provider or external system.

**Output**: A return value exposed by a Terraform module.

**Module**: A directory of Terraform configuration with inputs, resources, and outputs.

## Dynamic Terraform

**Meta-argument**: A Terraform argument that changes how Terraform handles a block, such as `count`, `for_each`, `depends_on`, or `lifecycle`.

**`count`**: A meta-argument that creates a numbered set of resource instances.

**`for_each`**: A meta-argument that creates one resource instance for each item in a map or set, using stable keys.

**Dynamic block**: A Terraform construct that generates repeated nested blocks inside a resource.

**Lifecycle rule**: Configuration that changes how Terraform creates, replaces, or destroys a resource.

## Platform Terms

**Backend**: The storage location and locking mechanism for Terraform state.

**Workspace**: A named Terraform state instance for the same configuration.

**Provisioner**: A Terraform mechanism for running commands during resource creation or destruction.

**Policy as code**: Versioned rules that check infrastructure changes before they are applied.

**Drift**: A difference between real infrastructure and Terraform's expected state.
