variable "rg_name" {}
variable "keyvault_unseal_name" {}
variable "keyvault_unseal_key" {}
variable "vnet_cidr" {
  default = "10.68.0.0/16"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
  }
}
