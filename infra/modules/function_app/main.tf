data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_storage_account" "sa" {
  name                     = "st${var.project}${var.env}func"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  allow_nested_items_to_be_public = false
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.project}-${var.env}-ep"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_user_assigned_identity" "mi" {
  name                = "uami-${var.project}-${var.env}-func"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
}

resource "azurerm_linux_function_app" "func" {
  name                = "func-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  identity {
  type         = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.mi.id]
  }

  site_config {
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    application_stack {
      dotnet_version = "8.0"
    }
    use_32_bit_worker   = false
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "SERVICEBUS_FQDN" = var.service_bus_fqdn
    "QUEUE_NAME"      = var.service_bus_queue_name
    "APPINSIGHTS_INSTRUMENTATIONKEY" = null
  }

  tags = {
    "skip-CloudGov-StoragAcc-SS" = "true"
  }
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnetint" {
  app_service_id = azurerm_linux_function_app.func.id
  subnet_id      = var.integration_subnet_id
}

# Private Endpoint for inbound to Function
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-func-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = var.private_endpoints_subnet_id
  private_service_connection {
    name                           = "funclink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_function_app.func.id
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "funczones"
    private_dns_zone_ids = [var.webapps_private_dns_zone_id]
  }
}

# RBAC: Function MI → Service Bus Data Sender
resource "azurerm_role_assignment" "sb_sender" {
  scope                = var.service_bus_namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.mi.principal_id
}

output "default_hostname" { value = azurerm_linux_function_app.func.default_hostname }
output "principal_id" { value = azurerm_user_assigned_identity.mi.principal_id }
