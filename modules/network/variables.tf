variable "vnet_cidr" {}
variable "location" {}
variable "rg_name" {}
variable "tags" {}

variable "dns_servers" {
  default = [
    "1.1.1.1", "9.9.9.9", "8.8.8.8", "8.8.4.4"
  ]
}

variable "hostbits" {
  default     = "8"
  description = "subnet host bits - double check"
}
variable "subnet_count" {
  description = "Number of Subnets"
  default     = "3"
}
