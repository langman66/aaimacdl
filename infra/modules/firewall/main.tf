resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.project}-${var.env}-afw"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.env}-hub"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_firewall_policy" "policy" {
  name                = "afwp-${var.project}-${var.env}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Premium"
  dns {
    proxy_enabled = var.dns_proxy_enabled
  }
}

resource "azurerm_firewall" "afw" {
  name                = "afw-${var.project}-${var.env}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.policy.id

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  # management_ip_configuration {
  #   name      = "mgmt"
  #   subnet_id = var.firewall_mgmt_subnet_id
  # }
}

# Minimal application rule collection to allow Azure + GitHub + Storage
resource "azurerm_firewall_policy_rule_collection_group" "rcg" {
  name               = "rcg-egress"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 100

  application_rule_collection {
    name     = "allow-required-egress"
    priority = 100
    action   = "Allow"

    rule {
      name = "azure-control-plane"
      source_addresses = ["10.20.0.0/16"]
      protocols {
        type = "Https"
        port = 443
      }
    }
    rule {
      name = "github"
      source_addresses = ["10.20.0.0/16"]
      protocols {
        type = "Https"
        port = 443
      }
    }
    rule {
      name = "azure-storage"
      source_addresses = ["10.20.0.0/16"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

# Route table to force egress via firewall
resource "azurerm_route_table" "rt" {
  name                = "rt-${var.project}-${var.env}-egress"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_route" "default" {
  name                   = "default-to-firewall"
  route_table_name       = azurerm_route_table.rt.name
  resource_group_name    = data.azurerm_resource_group.rg.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
}

# Associate route table to workload subnets
resource "azurerm_subnet_route_table_association" "func" {
  subnet_id      = data.azurerm_subnet.func.id
  route_table_id = azurerm_route_table.rt.id
}
resource "azurerm_subnet_route_table_association" "mgmt" {
  subnet_id      = data.azurerm_subnet.mgmt.id
  route_table_id = azurerm_route_table.rt.id
}
resource "azurerm_subnet_route_table_association" "jump" {
  subnet_id      = data.azurerm_subnet.jump.id
  route_table_id = azurerm_route_table.rt.id
}

# Lookups
data "azurerm_subnet" "func" {
  name                 = "snet-func-integration"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_subnet" "mgmt" {
  name                 = "snet-management"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_subnet" "jump" {
  name                 = "snet-jumpbox"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

output "firewall_private_ip" { value = azurerm_firewall.afw.ip_configuration[0].private_ip_address }
