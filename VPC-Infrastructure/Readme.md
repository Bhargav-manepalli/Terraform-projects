# Terraform Configuration for AWS Infrastructure

This repository contains a Terraform configuration for setting up a basic AWS infrastructure including VPC, subnets, route tables, internet gateway, NAT gateway, and EC2 instances. The configuration is modularized to enhance reusability and maintainability.

## Directory Structure

- `modules/`
  - `vpc/`
    - Contains the VPC module.
  - `subnets/`
    - Contains the subnet module.
  - `route_tables/`
    - Contains the route table module.
  - `internet_gateway/`
    - Contains the internet gateway module.
  - `NAT_gateway/`
    - Contains the NAT gateway module.
  - `Ec2/`
    - Contains the EC2 instance module.

## Configuration Overview

### VPC Module

The VPC module creates a Virtual Private Cloud (VPC) with the specified CIDR block.

```hcl
module "VPC" {
  source     = "./modules/vpc"
  cidr_block = "192.168.0.0/16"
}
```

### Subnet Module

The Subnet module creates public and private subnets within the VPC.

```hcl
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
```

### Route Table Module

The Route Table module creates route tables and associates them with the appropriate subnets.

```hcl
module "route_table" {
  source   = "./modules/route_tables"
  vpc_id   = module.VPC.vpc_id
  RT_count = var.subnet_ranges
}

resource "aws_route_table_association" "aws_route_table_association" {
  for_each       = module.Subnet.subnet_ids
  subnet_id      = each.value
  route_table_id = module.route_table.id[each.key]
}
```

### Internet Gateway Module

The Internet Gateway module creates an internet gateway and attaches it to the VPC.

```hcl
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.VPC.vpc_id
}

resource "aws_route" "route" {
  route_table_id         = lookup(module.route_table.id, "public")
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet_gateway.igw_id
}
```

### NAT Gateway Module

The NAT Gateway module creates a NAT gateway in the public subnet and sets up routing for private subnets.

```hcl
module "NAT_gateway" {
  source    = "./modules/NAT_gateway"
  subnet_id = module.Subnet.subnet_ids["public"]
}

resource "aws_route" "private_route" {
  route_table_id         = lookup(module.route_table.id, "private")
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.NAT_gateway.nat_gw_id
}
```

### EC2 Module

The EC2 module creates EC2 instances in the specified subnets.

```hcl
module "ec2" {
  source    = "./modules/Ec2"
  for_each  = module.Subnet.subnet_ids
  subnet_id = each.value
  key_name  = "Demo-server"
}
```

## Outputs

The following outputs are available:

- `subnet_ids`: List of subnet IDs created.
- `route_table_ids`: List of route table IDs created.
- `igw_id`: ID of the internet gateway created.
- `nat_gw_id`: ID of the NAT gateway created.

## Usage

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/your-repo-url.git
   ```

2. **Navigate to the Configuration Directory**:
   ```sh
   cd your-repo-directory
   ```

3. **Initialize Terraform**:
   ```sh
   terraform init
   ```

4. **Plan the Deployment**:
   ```sh
   terraform plan
   ```

5. **Apply the Configuration**:
   ```sh
   terraform apply
   ```

6. **Destroy the Infrastructure** (if needed):
   ```sh
   terraform destroy
   ```

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or later
- AWS Account with appropriate IAM permissions

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For more details on each module, please refer to the respective `README` files within the `modules/` directory.