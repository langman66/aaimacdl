data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.zone_names)
  name                = each.value
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = azurerm_private_dns_zone.zones
  name                  = replace(each.key, ".", "-")
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.vnet_id
}

output "zone_ids" {
  value = { for k, z in azurerm_private_dns_zone.zones : k => z.id }
}
