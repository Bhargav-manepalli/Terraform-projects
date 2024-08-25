output "id" {
  value = { for k, s in aws_route_table.route_table : k => s.id }
}