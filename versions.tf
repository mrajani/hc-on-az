terraform {
  required_version = "~> 1.0"
  required_providers {
    random   = "~> 2.3"
    template = "~> 2.2"
    local    = "~> 1.4"
    azurerm  = "~> 2.72"
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
