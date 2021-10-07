variable "tags_filter" {
  default = {
    "UseFor" = "Vault-Consul-AzSS"
  }
}
variable "rg_name" {}
variable "location" {}
variable "tags" {}

variable "application_port" {
  default = "80"
}

variable "vault_port" {
  default = "8200"
}
variable "vmss_vault_subnets" {}
variable "vault_azimage" {}
variable "app_config" {}
variable "managed_id" {}
variable "client_config" {}
variable "subscription" {}
