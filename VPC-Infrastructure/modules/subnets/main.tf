resource "aws_subnet" "aws_subnet" {
  for_each = var.subnet_ranges

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${each.key}_subnet"
  }
}
