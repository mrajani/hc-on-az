resource "azurerm_user_assigned_identity" "vault_ua_msi" {
  resource_group_name = var.rg_name
  location            = var.location
  name                = format("%s-vault-ua-msi", var.tags["Name"])
  tags                = var.tags
}
