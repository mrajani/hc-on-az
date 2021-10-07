output "rg" {
  value = data.azurerm_resource_group.current.name
}
output "client_config" {
  value = data.azurerm_client_config.current
}

output "key_vault" {
  value = [
    module.kms.az_key_vault.name,
    module.kms.az_key_vault.vault_uri
  ]
}

output "stacct_pkey" {
  value     = module.storageaccount.stacct_pkey
  sensitive = true
}
output "azimages" {
  value = module.azimages.azimages[*].name
}

output "azimage" {
  value = module.azimages.azimage
}
output "vmss_custom_data" {
  value     = module.vault.vmss_custom_data
  sensitive = true
}

output "data_vmss" {
  value = module.vault.data_vmss
}

output "managed_id" {
  value = module.vault.managed_id
}
