data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.project}-${var.env}-bastion"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bast-${var.project}-${var.env}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  ip_configuration {
    name                 = "cfg"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
