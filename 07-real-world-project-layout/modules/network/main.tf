# This is a skeletal teaching module. It uses outputs derived from inputs so the
# live stack can validate without creating real cloud resources.

locals {
  name = "${var.project}-${var.environment}-network"
}
