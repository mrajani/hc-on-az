output "custom_data" {
  value     = azurerm_linux_virtual_machine.bastion.custom_data
  sensitive = true
}
