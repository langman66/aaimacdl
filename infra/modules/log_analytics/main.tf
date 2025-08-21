resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
}

data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

output "law_id" { value = azurerm_log_analytics_workspace.law.id }
