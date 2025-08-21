data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.project}-${var.env}-ghrunner"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.project}-${var.env}-ghrunner"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_DS2_v2"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/aaimacdl/runner",
      "sudo chown ${var.admin_username}:${var.admin_username} /opt/aaimacdl/runner"
    ]
    connection {
      type = "ssh"
      user = var.admin_username
      host = self.public_ip_address
    }
  }
}

# Custom Script: install helper script (registration is interactive per docs)
resource "azurerm_virtual_machine_extension" "script" {
  name                 = "init-ghrunner"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings = <<SET
{
  "fileUris": [],
  "commandToExecute": "bash -lc 'cat > /opt/aaimacdl/runner/install_runner.sh <<\'EOF\'\n#!/usr/bin/env bash\nset -euo pipefail\ncd /opt/aaimacdl/runner\nVER=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep tag_name | cut -d\" -f4)\nwget -q https://github.com/actions/runner/releases/download/$VER/actions-runner-linux-x64-${VER#v}.tar.gz\ntar xzf actions-runner-linux-x64-*.tar.gz\nrm -f actions-runner-linux-x64-*.tar.gz\nread -p \"GitHub org (e.g. myorg): \" ORG\nread -p \"Repo name (e.g. myrepo): \" REPO\nread -p \"Runner registration token: \" TOKEN\n./config.sh --url https://github.com/$ORG/$REPO --token $TOKEN --labels self-hosted,aaimacdl,prod --unattended\nsudo ./svc.sh install\nsudo ./svc.sh start\necho \"Runner installed and started.\"\nEOF\nchmod +x /opt/aaimacdl/runner/install_runner.sh'"
}
SET
}
