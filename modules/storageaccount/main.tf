locals {
  location  = var.location
  rg_name   = var.rg_name
  tenant_id = var.tenant_id
  object_id = var.object_id
}

resource "azurerm_storage_account" "current" {
  name                     = format("%s%s", "rgstacct", var.tags["suffix"])
  location                 = local.location
  resource_group_name      = local.rg_name
  account_tier             = "standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}
