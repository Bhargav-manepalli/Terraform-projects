output "subnet_ids" {
  value = { for k, s in aws_subnet.aws_subnet : k => s.id }
}
