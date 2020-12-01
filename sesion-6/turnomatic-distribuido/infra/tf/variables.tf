variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-3"
}

variable "instance_size" {
  default = "t2.medium"
  description = "Base instance size we're using "
}