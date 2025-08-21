data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.project}-${var.env}-jumpbox"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.project}-${var.env}-jumpbox"
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
}
