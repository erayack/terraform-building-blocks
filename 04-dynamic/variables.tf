variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "demo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    private-a = { cidr = "10.40.1.0/24", az = "us-east-1a" }
    private-b = { cidr = "10.40.2.0/24", az = "us-east-1b" }
  }
}

variable "ingress_rules" {
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
  default = [
    { description = "HTTP from office", port = 80, cidr_blocks = ["10.0.0.0/8"] },
    { description = "HTTPS from office", port = 443, cidr_blocks = ["10.0.0.0/8"] }
  ]
}

variable "enable_logs" {
  type    = bool
  default = true
}

variable "log_retention_days" {
  type    = number
  default = 14
}
