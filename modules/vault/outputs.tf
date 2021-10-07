output "azimages" {
  value = data.azurerm_images.packer.images
}
output "azimage" {
  value = data.azurerm_image.packer.id
}

output "vmss_custom_data" {
  value = azurerm_linux_virtual_machine_scale_set.vault.custom_data
}
output "data_vmss" {
  value = data.azurerm_virtual_machine_scale_set.vault_vmss
}
output "managed_id" {
  value = azurerm_user_assigned_identity.vault_msi
}
