provider "aws" {
  region = var.aws_region
}

module "static_site" {
  source = "./modules/static-site"

  project     = var.project
  environment = var.environment
}
