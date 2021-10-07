locals {
  location = var.location
  rg_name  = var.rg_name

}

data "azurerm_key_vault" "vault" {
  name                = var.keyvault_unseal_name
  resource_group_name = local.rg_name
}

resource "azurerm_key_vault_access_policy" "unseal" {
  key_vault_id = data.azurerm_key_vault.vault.id
  tenant_id    = var.client_config.tenant_id
  object_id    = var.managed_id.principal_id
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

resource "azurerm_key_vault" "current" {
  name                = format("%s-kv-%s", var.tags["Name"], var.tags["suffix"])
  location            = local.location
  resource_group_name = local.rg_name
  tenant_id           = var.client_config.tenant_id
  sku_name            = "standard"

  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "self" {
  key_vault_id = azurerm_key_vault.current.id
  tenant_id    = var.client_config.tenant_id
  object_id    = var.client_config.object_id
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

resource "azurerm_key_vault_access_policy" "mi" {
  key_vault_id = azurerm_key_vault.current.id
  tenant_id    = var.client_config.tenant_id
  object_id    = var.managed_id.principal_id
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

resource "azurerm_key_vault_key" "generated" {
  name         = format("%s-key-%s", var.tags["Name"], var.tags["suffix"])
  key_vault_id = azurerm_key_vault.current.id
  key_type     = "RSA"
  key_size     = 2048
  tags         = var.tags
  key_opts     = ["decrypt", "encrypt", "sign", "verify", "unwrapKey", "wrapKey"]
  depends_on = [
    azurerm_key_vault_access_policy.mi,
    azurerm_key_vault_access_policy.self
  ]
}

resource "random_string" "vm_password" {
  length = 16
}
resource "azurerm_key_vault_secret" "generated" {
  name         = format("%s-secret-%s", var.tags["Name"], var.tags["suffix"])
  value        = random_string.vm_password.result
  key_vault_id = azurerm_key_vault.current.id
  tags         = var.tags
  depends_on = [
    azurerm_key_vault_access_policy.mi,
    azurerm_key_vault_access_policy.self
  ]
}
