resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.env}-hub"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.env}-hub"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
}

# Subnets
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.0.0/26"]
}

resource "azurerm_subnet" "firewall_mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.0.64/26"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.0.128/26"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.0.192/27"]
}

resource "azurerm_subnet" "func_integration" {
  name                 = "snet-func-integration"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.2.0/26"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.3.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.4.0/24"]
}

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.5.0/24"]
}

output "rg_name" { value = azurerm_resource_group.rg.name }
output "vnet_id" { value = azurerm_virtual_network.vnet.id }
output "firewall_subnet_id" { value = azurerm_subnet.firewall.id }
output "firewall_mgmt_subnet_id" { value = azurerm_subnet.firewall_mgmt.id }
output "bastion_subnet_id" { value = azurerm_subnet.bastion.id }
output "appgw_subnet_id" { value = azurerm_subnet.appgw.id }
output "func_integration_subnet_id" { value = azurerm_subnet.func_integration.id }
output "private_endpoints_subnet_id" { value = azurerm_subnet.private_endpoints.id }
output "jumpbox_subnet_id" { value = azurerm_subnet.jumpbox.id }
output "management_subnet_id" { value = azurerm_subnet.management.id }
