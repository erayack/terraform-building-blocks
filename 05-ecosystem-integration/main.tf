terraform {
  required_version = ">= 1.6.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

locals {
  environment = terraform.workspace
}

resource "null_resource" "handoff_to_configuration" {
  triggers = {
    environment  = local.environment
    playbook_sha = filesha256("${path.module}/playbook.yml")
  }

  provisioner "local-exec" {
    command = "echo Run Ansible or Bash bootstrap for ${self.triggers.environment}"
  }
}

output "workspace_environment" {
  value = local.environment
}
