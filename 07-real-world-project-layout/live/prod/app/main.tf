module "app" {
  source = "../../../modules/app"

  project      = var.project
  environment  = var.environment
  network_name = var.network_name
  subnet_ids   = var.subnet_ids
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

output "app_name" {
  value = module.app.app_name
}

output "subnet_count" {
  value = module.app.subnet_count
}
