resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  for_each = var.RT_count
  tags = {"Name" = "${each.key}_RT"}
}



