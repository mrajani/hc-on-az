locals {
  location  = var.location
  rg_name   = var.rg_name
  tenant_id = var.tenant_id
  object_id = var.object_id
}

resource "azurerm_key_vault" "current" {
  name                = format("%s-key-%s", var.tags["Name"], var.tags["suffix"])
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
      "Get", "List", "Create", "Delete", "Update", "Purge", "WrapKey", "UnwrapKey"
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Purge"
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

resource "random_string" "vm_password" {
  length = 16
}
resource "azurerm_key_vault_secret" "generated" {
  name         = format("%s-azsecret", var.rg_name)
  value        = random_string.vm_password.result
  key_vault_id = azurerm_key_vault.current.id
  tags         = var.tags

}
