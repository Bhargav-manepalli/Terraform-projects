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


resource "aws_iam_user" "name" {
  name = var.iam_user_name
}

resource "aws_instance" "application-server" {
  ami           = data.aws_ami.name.image_id
  instance_type = var.aws_instance_type

  provisioner "local-exec" {
    command = "echo 'Resource Created Successfully and it's public ip is : ${self.public_ip}' "
  }

  provisioner "local-exec" {
    command = "echo 'Destroying the instance : ${self.public_ip}'"
    when    = destroy
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
