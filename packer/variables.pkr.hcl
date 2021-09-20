# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2S_v3"
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_sku" {
  type    = string
  default = "18.04-LTS"
}

variable "image_offer" {
  type    = string
  default = "UbuntuServer"
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "image_prefix" {
  type    = string
  default = "vault-consul"
}
