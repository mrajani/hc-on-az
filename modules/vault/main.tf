locals {
  ssh_key = format("%s-ssh-key", var.tags["Name"]) #"vault_ssh_key"
}

data "azurerm_images" "packer" {
  resource_group_name = var.rg_name
  tags_filter         = var.tags_filter
}

data "azurerm_image" "packer" {
  name_regex          = "vault-consul-"
  resource_group_name = var.rg_name
}

resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "azurerm_ssh_public_key" "vault" {
  name                = local.ssh_key
  location            = var.location
  resource_group_name = var.rg_name
  public_key          = tls_private_key.vault.public_key_openssh
}
resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_network_security_group" "nsg_vmss" {
  name                = format("%s-nsg-vmss", var.tags["Name"])
  location            = var.location
  resource_group_name = var.rg_name
  security_rule {
    name                       = "ingress-ssh-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443", "8200"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vault" {
  name                = format("%s-vault-lb-pub-ip", var.tags["Name"])
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", var.tags["Name"], random_string.fqdn.result)
  tags                = var.tags
}

resource "azurerm_lb" "vault" {
  name                = format("%s-vault-lb", var.tags["Name"])
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = format("%s-fe-ipcfg", var.tags["Name"])
    public_ip_address_id = azurerm_public_ip.vault.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vault.id
  name            = format("%s-backend-addr-pool", var.tags["Name"])
}

resource "azurerm_lb_probe" "vault" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.vault.id
  name                = format("%s-http-probe", var.tags["Name"])
  port                = var.vault_port
}

resource "azurerm_lb_rule" "https" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.vault.id
  name                           = "HTTPS"
  protocol                       = "TCP"
  frontend_port                  = "443"
  backend_port                   = var.vault_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = format("%s-fe-ipcfg", var.tags["Name"])
  probe_id                       = azurerm_lb_probe.vault.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vault" {
  name                 = format("%s-vmss", var.tags["Name"])
  location             = var.location
  resource_group_name  = var.rg_name
  computer_name_prefix = "vault-"
  # Need to fix this
  # zone_balance        = true
  # zones               = ["1", "2", "3"]
  sku            = "Standard_DS1_v2"
  instances      = 3
  admin_username = "ubuntu"
  custom_data    = data.cloudinit_config.custom_data.rendered
  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.vault.public_key_openssh
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vault_ua_msi.id]
  }

  source_image_id = var.vault_azimage
  zones           = ["1", "2", "3"]
  zone_balance    = true
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = format("%s-nic", var.tags["Name"])
    primary = true

    ip_configuration {
      name      = format("%s-ipconfig", var.tags["Name"])
      primary   = true
      subnet_id = var.vmss_vault_subnets[0]

      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
    network_security_group_id = azurerm_network_security_group.nsg_vmss.id
  }

  # identity {
  #   type         = "UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.vault_msi.idƒ]
  # }
  # tags = var.tags # vault_consul_member
  tags = merge(
    var.tags,
    tomap({ "vault_consul_member" = "join" })
  )
}

resource "local_file" "private_pem" {
  content         = tls_private_key.vault.private_key_pem
  filename        = pathexpand("~/.ssh/${local.ssh_key}.pem")
  file_permission = "0600"
}

resource "local_file" "public_openssh" {
  content         = tls_private_key.vault.public_key_openssh
  filename        = pathexpand("~/.ssh/${local.ssh_key}.pub")
  file_permission = "0644"
}

output "vault_ssh_key" {
  value = azurerm_ssh_public_key.vault.name
}


data "cloudinit_config" "custom_data" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-config.yml",
      {
        vault_version = "1.8.4"
        userlogin     = "ubuntu"
    })
  }
}
