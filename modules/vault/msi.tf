resource "azurerm_user_assigned_identity" "vault_msi" {
  resource_group_name = var.rg_name
  location            = var.location
  name                = format("%s-vault-msi", var.tags["Name"])
  tags                = var.tags
}

resource "azurerm_role_assignment" "vault" {
  scope                = var.managed_id.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.managed_id.principal_id
}

resource "azurerm_role_assignment" "reader_role" {
  scope                = var.subscription.id
  role_definition_name = "Reader"
  principal_id         = var.managed_id.principal_id
}
