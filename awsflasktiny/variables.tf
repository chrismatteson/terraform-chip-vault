variable "project_tag" {
  type    = string
  default = "flask-app"
}
variable "tags" {
  description = "Map of extra tags to attach to items which accept them"
  type        = map(string)
  default     = {}
}
variable "ssh_key_name" { default = "" }
variable "ami_filter_owners" {
  description = "When bash install method, use a filter to lookup an image owner and name. Common combinations are 206029621532 and amzn2-ami-hvm* for Amazon Linux 2 HVM, and 099720109477 and ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-* for Ubuntu 18.04"
  type        = list(string)
  default     = ["099720109477"]
}
variable "ami_filter_name" {
  description = "When bash install method, use a filter to lookup an image owner and name. Common combinations are 206029621532 and amzn2-ami-hvm* for Amazon Linux 2 HVM, and 099720109477 and ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-* for Ubuntu 18.04"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
}
variable "vpc1_id" {
  type    = string
  default = ""
}
variable "vpc1_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc2_id" {
  type    = string
  default = ""
}
variable "vpc2_region" {
  type    = string
  default = "us-west-2"
}
variable "vpc3_id" {
  type    = string
  default = ""
}
variable "vpc3_region" {
  type    = string
  default = "eu-central-1"
}
