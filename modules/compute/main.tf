#---------- Create SSH Keys for Bastion VM --------------#
locals {
  location = var.location
  rg_name  = var.rg_name
  ssh_key  = "bastion_ssh_key"
}
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "azurerm_ssh_public_key" "bastion" {
  name                = local.ssh_key
  location            = local.location
  resource_group_name = local.rg_name
  public_key          = tls_private_key.bastion.public_key_openssh
}

#-------- Create Azure Public IP --------#
resource "azurerm_public_ip" "ip" {
  name                = format("%s-bastion-ip", var.tags["Name"])
  location            = local.location
  resource_group_name = local.rg_name
  allocation_method   = "Dynamic"
}

#-------- Create Azure Private Network Interface --------#
resource "azurerm_network_interface" "nic" {
  name                = format("%s-bastion-nic", var.tags["Name"]) # "${local.rg_name}-nic"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "bastion-internal"
    subnet_id                     = var.public_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
  tags = var.tags
}

resource "azurerm_network_security_group" "nsg_bastion" {
  name                = format("%s-nsg-bastion", var.tags["Name"])
  location            = var.location
  resource_group_name = var.rg_name
  security_rule {
    name                       = "ingress-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = var.public_subnets[0]
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg_bastion
  ]
}

data "cloudinit_config" "custom_data" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = <<-EOL
    package_update: true
    packages:
      - python3-pip
      - jq
    runcmd:
      - pip3 install ansible
    EOL
  }
}
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = format("%s-bastion-vm", var.tags["Name"])
  location              = local.location
  resource_group_name   = local.rg_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2" # keep it fixed just for ssh
  admin_username        = "ubuntu"

  custom_data = data.cloudinit_config.custom_data.rendered

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal" # "UbuntuServer"
    sku       = "20_04-lts-gen2"               # "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "bastion_osdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_ssh_key {
    username   = "ubuntu"
    public_key = azurerm_ssh_public_key.bastion.public_key
  }
  tags = var.tags
}

resource "local_file" "private_pem" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = pathexpand("~/.ssh/${local.ssh_key}.pem")
  file_permission = "0600"
}

resource "local_file" "public_openssh" {
  content         = tls_private_key.bastion.public_key_openssh
  filename        = pathexpand("~/.ssh/${local.ssh_key}.pub")
  file_permission = "0644"
}

output "bastion_ip" {
  value = azurerm_linux_virtual_machine.bastion.public_ip_address
}

output "bastion_ssh_key" {
  value = azurerm_ssh_public_key.bastion.name
}
