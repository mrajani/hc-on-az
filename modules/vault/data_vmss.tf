data "azurerm_virtual_machine_scale_set" "vault_vmss" {
  resource_group_name = var.rg_name
  name                = azurerm_linux_virtual_machine_scale_set.vault.name
}
