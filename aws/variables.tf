variable "scenario_1_users" {
  type    = list(map(string))
  default = []
}
variable "scenario_2_users" {
  type    = list
  default = []
}
variable "scenario_3_users" {
  type    = list
  default = []
}
variable "scenario_4_users" {
  type    = list
  default = []
}
variable "scenario_5_users" {
  type    = list
  default = []
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
