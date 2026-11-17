variable "region" { type = string
 default = "ap-south-1" }
variable "project_name" { type = string
 default = "tutedude-devops" }
variable "ami_id" { type = string
 description = "Ubuntu 22.04 AMI ID for the selected region" }
variable "instance_type" { type = string
 default = "t3.micro" }
variable "key_name" { type = string
 description = "Existing EC2 key pair name" }
variable "allowed_cidr" { type = string
 description = "Your public IP /32
 avoid 0.0.0.0/0 for SSH" }
