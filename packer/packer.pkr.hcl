packer {
  required_version = ">= 1.7.4"
}

source "azure-arm" "focal-vhd" {
  #client_id                         = "${var.client_id}"
  #client_secret                     = "${var.client_secret}"
  #subscription_id                   = "${var.subscription_id}"
  #tenant_id                         = "${var.tenant_id}"

  azure_tags = {
    Distro              = "Ubuntu"
    UseFor              = "Vault-Consul-AzSS"
    dept                = "DevOps"
    task                = "Image deployment"
    vault_consul_member = "join"
  }
  use_azure_cli_auth                = true
  build_resource_group_name         = "${var.rg_name}"
  image_offer                       = "${var.image_offer}"
  image_publisher                   = "${var.image_publisher}"
  image_sku                         = "${var.image_sku}"
  managed_image_name                = "${var.image_prefix}-{{uuid}}"
  managed_image_resource_group_name = "${var.rg_name}"
  os_type                           = "${var.os_type}"
  vm_size                           = "${var.vm_size}"
}

build {
  sources = ["source.azure-arm.focal-vhd"]

  provisioner "file" {
    sources = [
      "./certificates/ca.crt.pem",
      "./certificates/vault.crt.pem",
      "./certificates/vault.key.pem",
      "az_keyvault_vars.yml"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo cp /tmp/ca.crt.pem /usr/local/share/ca-certificates/ionovault.crt",
      "sudo /usr/sbin/update-ca-certificates",
      "sudo cp /tmp/*.*.pem /usr/local/etc/",
      "sudo cp /tmp/az_keyvault_vars.yml /usr/local/etc/",
    ]
    inline_shebang = "/bin/sh -x"
    only           = ["azure-arm.focal-vhd"]
    pause_before   = "5s"
    pause_after    = "5s"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }
}
