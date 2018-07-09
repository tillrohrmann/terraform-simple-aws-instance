variable "region" {
  default = "eu-central-1"
}

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

variable "worker_root_volume_size" {
  default = 25
}

variable "run_id" {}