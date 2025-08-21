data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_servicebus_namespace" "ns" {
  name                = "sb-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Premium"
  capacity            = 1
  premium_messaging_partitions = 1
  public_network_access_enabled = false
  local_auth_enabled            = false
}

resource "azurerm_servicebus_queue" "q" {
  name                = "q-${var.project}-hub"
  namespace_id        = azurerm_servicebus_namespace.ns.id
  max_size_in_megabytes = 1024
}

# Private Endpoint + DNS
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-sb-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = var.private_subnet_id
  private_service_connection {
    name                           = "sblink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_servicebus_namespace.ns.id
    subresource_names              = ["namespace"]
  }
  private_dns_zone_group {
    name                 = "sbzones"
    private_dns_zone_ids = [var.sb_private_dns_zone_id]
  }
}

output "namespace_id" { value = azurerm_servicebus_namespace.ns.id }
output "fqdn" { value = azurerm_servicebus_namespace.ns.default_primary_connection_string_hostname }
output "queue_name" { value = azurerm_servicebus_queue.q.name }
