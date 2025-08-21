resource "azurerm_resource_group" "state" {
  name     = "rg-${var.project}-${var.env}-tfstate"
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                     = "st${var.project}${var.env}tfstate"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  allow_nested_items_to_be_public = false
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

output "backend_hcl" {
  value = <<EOT
resource_group_name  = "${azurerm_resource_group.state.name}"
storage_account_name = "${azurerm_storage_account.state.name}"
container_name       = "${azurerm_storage_container.state.name}"
key                  = "${var.project}-${var.env}.tfstate"
EOT
}
