variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnets" {
  type = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  type = map(string)
  default = {
    a = "10.0.3.0/24"
    b = "10.0.4.0/24"
  }
}
