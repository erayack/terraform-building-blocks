module "network" {
  source = "../../../modules/network"

  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

output "network_name" {
  value = module.network.network_name
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "subnet_ids" {
  value = module.network.subnet_ids
}
