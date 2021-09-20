
resource "azurerm_private_dns_zone" "vault" {
  name                = var.vault_domain_name
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault" {
  name                  = format("%s-privatednszone-vnet-link", var.tags["Name"])
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
  tags                  = var.tags
}
