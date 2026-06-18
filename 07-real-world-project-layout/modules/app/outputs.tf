output "app_name" {
  value = local.app_name
}

output "network_name" {
  value = var.network_name
}

output "subnet_count" {
  value = length(var.subnet_ids)
}
