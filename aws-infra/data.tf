data "aws_ami" "name" {
  owners     = ["amazon"]
  name_regex = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240701"
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
