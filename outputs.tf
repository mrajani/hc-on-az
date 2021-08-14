output "rg" {
  value = data.azurerm_resource_group.current.name
}

output "client_config" {
  value = data.azurerm_client_config.current
}
