variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
