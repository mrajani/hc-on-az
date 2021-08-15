data "azurerm_resource_group" "current" {
  name = var.rg_name
}
data "azurerm_client_config" "current" {}

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

module "kms" {
  source    = "./modules/kms"
  location  = data.azurerm_resource_group.current.location
  rg_name   = data.azurerm_resource_group.current.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  tags = merge(
    var.tags,
    data.azurerm_resource_group.current.tags
  )
}
