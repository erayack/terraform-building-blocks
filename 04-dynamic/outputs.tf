output "private_subnet_ids" {
  value = { for name, subnet in aws_subnet.private : name => subnet.id }
}

output "security_group_id" {
  value = aws_security_group.app.id
}
