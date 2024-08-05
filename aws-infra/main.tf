resource "aws_iam_user" "iam_username" {
  name = var.iam_user_name
}

resource "aws_key_pair" "name" {
  key_name   = var.key_name
  public_key = file("./${var.key_name}.pub")
}

resource "aws_security_group" "application-sg" {
  name        = "application-sg"
  description = "Security group for application-webserver"

  dynamic "ingress" {
    for_each = toset(var.aws_security_group_ports)
    content {
      to_port          = ingress.key
      from_port        = ingress.key
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "application-server" {
  ami                    = data.aws_ami.name.image_id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.application-sg.id]
  key_name               = var.key_name

  connection {
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("${path.module}/web-server")
    type        = "ssh"
  }

  provisioner "file" {
    source      = "./config_files/setup.sh"
    destination = "/home/ubuntu/setup.sh"

    connection {
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("${path.module}/web-server")
      type        = "ssh"
    }
  }

  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu/setup.sh", "./setup.sh"]
  }

  provisioner "local-exec" {
    command = "echo 'Resource Created Successfully and it's public ip is : ${self.public_ip} \n You can access the website at : http://${self.public_ip}:80/' "
  }

  provisioner "local-exec" {
    command = "echo 'Destroying the instance : ${self.public_ip}'"
    when    = destroy
  }

  lifecycle {
    ignore_changes = [tags]
  }
}


resource "aws_ami_from_instance" "web-server-ami" {
  source_instance_id = aws_instance.application-server.id
  name               = "web-server-ami"
}

resource "aws_launch_template" "webserver-launch-template" {
  name                   = "webserver-launch-template"
  image_id               = aws_ami_from_instance.web-server-ami.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.application-sg.id]
  key_name               = var.key_name
}

output "aws_launch_template_id" {
  value = aws_launch_template.webserver-launch-template.id
}