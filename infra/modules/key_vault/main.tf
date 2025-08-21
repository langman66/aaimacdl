data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${var.project}-${var.env}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)
  sku_name                   = "standard"
  purge_protection_enabled   = true
  public_network_access_enabled = false
}

data "azurerm_client_config" "current" {}

# Admin access policy (or RBAC, simplified here)
resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_key_vault.kv.tenant_id
  object_id    = var.admin_object_id
  secret_permissions = ["Get","List","Set","Delete"]
  certificate_permissions = ["Get","List","Create","Delete","Import","Update"]
}

# Private Endpoint
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-kv-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = var.private_subnet_id
  private_service_connection {
    name                           = "kvlink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "kvzones"
    private_dns_zone_ids = [var.kv_private_dns_zone_id]
  }
}

# Placeholder output for cert secret id (created later via CLI or azurerm_key_vault_certificate)
output "agw_cert_secret_id" { value = "${azurerm_key_vault.kv.id}/secrets/agw-tls-aaimacdl" }
output "vault_id" { value = azurerm_key_vault.kv.id }
