data "azurerm_resource_group" "rg" { name = "rg-${var.project}-${var.env}-hub" }

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.project}-${var.env}-agw"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }
  autoscale_configuration { min_capacity = 1 }

  gateway_ip_configuration {
    name      = "gwipc"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  ssl_certificate {
    name                = "from-kv"
    key_vault_secret_id = var.key_vault_secret_id
  }

  backend_address_pool {
    name  = "funcpool"
    fqdns = [var.backend_fqdn]
  }

  backend_http_settings {
    name                  = "https-settings"
    port                  = 443
    protocol              = "Https"
    cookie_based_affinity = "Disabled"
    pick_host_name_from_backend_address = true
    request_timeout       = 30
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "from-kv"
  }

  request_routing_rule {
    name                       = "rule-root"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "funcpool"
    backend_http_settings_name = "https-settings"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

output "public_ip" { value = azurerm_public_ip.pip.ip_address }
