output "public_subnets" {
  value = azurerm_subnet.public[*].id
}

output "private_subnets" {
  value = azurerm_subnet.private[*].id
}

output "db_subnets" {
  value = azurerm_subnet.db[*].id
}
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
