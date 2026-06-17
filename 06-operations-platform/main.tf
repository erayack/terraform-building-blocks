terraform {
  required_version = ">= 1.6.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "service_name" {
  type    = string
  default = "payments"
}

variable "owner" {
  type    = string
  default = "platform-team@example.com"
}

resource "random_pet" "release" {
  length = 2

  keepers = {
    service = var.service_name
    owner   = var.owner
  }
}

output "release_name" {
  value = "${var.service_name}-${random_pet.release.id}"
}
