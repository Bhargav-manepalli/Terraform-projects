variable "iam_user_name" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "aws_security_group_ports" {
  type = list(number)
}

variable "key_name" {
  type = string
}