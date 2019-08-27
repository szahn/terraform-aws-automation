variable "aws_region" {}
variable "localip" {}
variable "key_name" {}
variable "public_key_path" {}
variable "dev_instance_type" {}
variable "dev_ami" {}
variable "cidrs" {
  type = "map"
}
