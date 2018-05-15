variable "access_key" {}
variable "secret_key" {}
variable "role_arn" {}
variable "region" {
  default = "eu-central-1"
}
variable "key_name" {}
variable "instance_type" {
  default = "m4.xlarge"
}
variable "ami" {
  # The default is Debian 8.7 Jessie AMI in the eu-central-1 region.
  # https://wiki.debian.org/Cloud/AmazonEC2Image/Jessie
  default = "ami-5900cc36"
}
variable "vpc_id" {
  default = "vpc-03ca2768"
}
