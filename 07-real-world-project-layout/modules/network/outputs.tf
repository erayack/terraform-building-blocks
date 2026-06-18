output "network_name" {
  value = local.name
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "subnet_ids" {
  value = [
    "example-subnet-a",
    "example-subnet-b"
  ]
}
