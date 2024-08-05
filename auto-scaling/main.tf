data "terraform_remote_state" "aws-infra-state" {
  backend = "local"
  config = {
    path = "../aws-infra/terraform.tfstate"
  }
}

output "id" {
  value = data.terraform_remote_state.aws-infra-state.outputs.aws_launch_template_id
}


resource "aws_autoscaling_group" "web-server-autoscaling" {
  availability_zones = ["us-east-1a"]
  desired_capacity = 1
  max_size = 1
  min_size = 1

  launch_template {
    id = data.terraform_remote_state.aws-infra-state.outputs.aws_launch_template_id
  }

}
