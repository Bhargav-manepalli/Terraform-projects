resource "aws_eip" "eip" {
  domain           = "vpc"
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "gw-NAT"
  }
}