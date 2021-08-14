variable "rg_name" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

variable "vnet_cidr" {
  default = "10.172.0.0/16"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
  }
}

