output "azimages" {
  value = data.azurerm_images.packer.images
}
output "azimage" {
  value = data.azurerm_image.packer.id
}
