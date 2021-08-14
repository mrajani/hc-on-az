#-------- Create Azure VNET --------#
locals {
  location = var.location
  rg_name  = var.rg_name
}
resource "azurerm_virtual_network" "main" {
  name                = format("%s-vnet", var.tags["Name"])
  address_space       = [var.vnet_cidr]
  location            = local.location
  resource_group_name = local.rg_name
  dns_servers         = var.dns_servers
  tags                = var.tags
}


#-------- Create Public, Private, DB subnets --------#
resource "azurerm_subnet" "public" {
  count                = var.subnet_count
  name                 = format("%s-snet-pub-%s", var.tags["Name"], count.index)
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, var.hostbits, count.index)]
}

resource "azurerm_subnet" "private" {
  count                = var.subnet_count
  name                 = format("%s-snet-pri-%s", var.tags["Name"], count.index)
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, var.hostbits, count.index + 1 * var.subnet_count)]
}

resource "azurerm_subnet" "db" {
  count                = var.subnet_count
  name                 = format("%s-snet-db-%s", var.tags["Name"], count.index)
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, var.hostbits, count.index + 2 * var.subnet_count)]
}
