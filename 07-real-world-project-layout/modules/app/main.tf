# This is a skeletal teaching module. A real app module might create a load
# balancer, service, IAM role, or compute resources.

locals {
  app_name = "${var.project}-${var.environment}-app"
}
