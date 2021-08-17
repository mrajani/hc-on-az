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

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  access_policy {
    tenant_id = local.tenant_id
    object_id = local.object_id
    key_permissions = [
      "get", "list", "create", "delete", "update"
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
  }
  tags = var.tags
}

resource "azurerm_key_vault_key" "generated" {
  name         = format("%s-azkey", var.rg_name)
  key_vault_id = azurerm_key_vault.current.id
  key_type     = "RSA"
  key_size     = 2048
  tags         = var.tags
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
