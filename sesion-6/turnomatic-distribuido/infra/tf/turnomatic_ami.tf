data "aws_ami" "this" {
  most_recent = true
  name_regex  = "^sre-turnomatic-ami-.*"
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["turnomatic-ami"]
  }

}