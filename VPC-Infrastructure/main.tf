module "VPC" {
  source     = "./modules/vpc"
  cidr_block = "192.168.0.0/16"
}

variable "subnet_ranges" {
  type = map(any)
  default = {
    "public"  = "192.168.1.0/24"
    "private" = "192.168.2.0/24"
  }
}

module "Subnet" {
  source        = "./modules/subnets"
  vpc_id        = module.VPC.vpc_id
  subnet_ranges = var.subnet_ranges
}

output "subnet_ids" {
  value = module.Subnet.subnet_ids
}

module "route_table" {
  source   = "./modules/route_tables"
  vpc_id   = module.VPC.vpc_id
  RT_count = var.subnet_ranges
}

output "route_table_ids" {
  value = module.route_table.id
}


resource "aws_route_table_association" "aws_route_table_association" {
  for_each       = module.Subnet.subnet_ids
  subnet_id      = each.value
  route_table_id = module.route_table.id[each.key]
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.VPC.vpc_id
}

output "igw_id" {
  value = module.internet_gateway.igw_id
}

resource "aws_route" "route" {
  route_table_id         = lookup(module.route_table.id, "public")
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet_gateway.igw_id
}


module "NAT_gateway" {
  source = "./modules/NAT_gateway"
  subnet_id = module.Subnet.subnet_ids["public"]
}

resource "aws_route" "private_route" {
  route_table_id         = lookup(module.route_table.id, "private")
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.NAT_gateway.nat_gw_id
}

module "ec2" {
  source    = "./modules/Ec2"
  for_each  = module.Subnet.subnet_ids
  subnet_id = each.value
  key_name  = "Demo-server"
}
