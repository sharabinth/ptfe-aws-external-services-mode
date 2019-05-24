variable "aws_region" {
  # Sydney DC
  default = "ap-southeast-2"
}

variable "amis" {
  # ubuntu xenial in Sydney DC
  default = "ami-05f29a2b825ca5210"
}

variable "instance_type" {
  default = "m5.large"
}

variable "ssh_key_name" {
  default = "msb-ap-se-2"
}

variable "owner" {
  default = "maha"
}

variable "resource_prefix_name" {
  default = "maha-ptfe"
}

variable "ebs_volume_size" {
  default = 80
}

variable "ebs_volume_type" {
  default = "gp2"
}
