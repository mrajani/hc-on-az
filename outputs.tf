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
