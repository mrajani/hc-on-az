terraform {
  required_version = "~> 1.0"
  required_providers {
    random    = "~> 2.3"
    template  = "~> 2.2"
    local     = "~> 1.4"
    cloudinit = "~> 2.2"
    tls       = "~> 3.1"
    azurerm   = ">= 2.75"
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
