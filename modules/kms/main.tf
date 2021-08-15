locals {
  location  = var.location
  rg_name   = var.rg_name
  tenant_id = var.tenant_id
  object_id = var.object_id
}

resource "azurerm_key_vault" "current" {
  name                = format("%s-key", var.tags["Name"])
  location            = local.location
  resource_group_name = local.rg_name
  tenant_id           = local.tenant_id
  sku_name            = "standard"
  access_policy {
    tenant_id = local.tenant_id
    object_id = local.object_id
    key_permissions = [
      "get", "list", "create", "delete", "update",
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
  }
  tags = var.tags
}
