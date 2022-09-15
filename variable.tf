variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}
variable "cidrs_public1" {}
variable "cidrs_private1" {}
variable "key_name" {}
variable "public_key_path" {}
variable "instance_type" {}
variable "manager_count" {}
variable "worker_count" {}
variable "ami" {}
variable "private_key_path" {}
