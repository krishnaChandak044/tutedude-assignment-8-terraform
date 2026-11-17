variable "region" {

  type    = string
  default = "ap-southeast-2"
}
variable "project_name" {
  type    = string
  default = "tutedude-devops"
}
variable "image_tag" {
  type    = string
  default = "latest"
}
variable "container_cpu" {
  type    = number
  default = 256
}
variable "container_memory" {
  type    = number
  default = 512
}

variable "deploy_services" {
  type        = bool
  description = "Set true only after both container images are pushed to ECR"
  default     = false
}
