data "azurerm_resource_group" "current" {
  name = var.rg_name
}
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}


resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}
module "network" {
  source    = "./modules/network"
  vnet_cidr = var.vnet_cidr
  location  = data.azurerm_resource_group.current.location
  rg_name   = data.azurerm_resource_group.current.name
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )
}
module "storageaccount" {
  source    = "./modules/storageaccount"
  location  = data.azurerm_resource_group.current.location
  rg_name   = data.azurerm_resource_group.current.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags,
    {
      suffix = random_string.suffix.result
    }
  )
}

module "kms" {
  source               = "./modules/kms"
  location             = data.azurerm_resource_group.current.location
  rg_name              = data.azurerm_resource_group.current.name
  client_config        = data.azurerm_client_config.current
  tenant_id            = data.azurerm_client_config.current.tenant_id
  object_id            = data.azurerm_client_config.current.object_id
  managed_id           = module.vault.managed_id
  keyvault_unseal_name = var.keyvault_unseal_name
  keyvault_unseal_key  = var.keyvault_unseal_key
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags,
    {
      suffix = random_string.suffix.result
    }
  )
}

module "azimages" {
  source   = "./modules/azimages"
  location = data.azurerm_resource_group.current.location
  rg_name  = data.azurerm_resource_group.current.name
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )

}
module "compute" {
  source         = "./modules/compute"
  location       = data.azurerm_resource_group.current.location
  rg_name        = data.azurerm_resource_group.current.name
  public_subnets = module.network.public_subnets
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )
}
module "vault" {
  source             = "./modules/vault"
  location           = data.azurerm_resource_group.current.location
  rg_name            = data.azurerm_resource_group.current.name
  vmss_vault_subnets = module.network.private_subnets
  vault_azimage      = module.azimages.azimage
  managed_id         = module.vault.managed_id
  subscription       = data.azurerm_subscription.primary
  client_config      = data.azurerm_client_config.current
  app_config         = "vault-appconf-${random_string.suffix.result}"
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )
}

module "dns" {
  source   = "./modules/dns"
  location = data.azurerm_resource_group.current.location
  rg_name  = data.azurerm_resource_group.current.name
  vnet_id  = module.network.vnet_id
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )
}
