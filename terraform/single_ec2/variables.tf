variable "region" {

  type    = string
  default = "ap-southeast-2"
}
variable "project_name" {
  type    = string
  default = "tutedude-devops"
}
variable "allowed_ssh_cidr" {
  type        = string
  description = "Your public IPv4 CIDR /32 for SSH"
}
variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}
variable "ami_id" {
  type        = string
  description = "Ubuntu 22.04 AMI ID for ap-southeast-2"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
