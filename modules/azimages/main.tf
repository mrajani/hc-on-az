locals {
  location = var.location
  rg_name  = var.rg_name
}

data "azurerm_images" "packer" {
  resource_group_name = local.rg_name
  tags_filter         = var.tags_filter
}

data "azurerm_image" "packer" {
  name_regex          = "vault-consul-"
  resource_group_name = var.rg_name
}
