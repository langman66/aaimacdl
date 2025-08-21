module "remote_state" {
  source          = "../../modules/remote_state"
  subscription_id = var.subscription_id
  location        = var.location
  project         = var.project
  env             = var.env
}

module "network" {
  source   = "../../modules/vnet"
  project  = var.project
  env      = var.env
  location = var.location
  address_space = ["10.20.0.0/16"]
}

module "firewall" {
  source                   = "../../modules/firewall"
  project                  = var.project
  env                      = var.env
  location                 = var.location
  vnet_id                  = module.network.vnet_id
  firewall_subnet_id       = module.network.firewall_subnet_id
  firewall_mgmt_subnet_id  = module.network.firewall_mgmt_subnet_id
  dns_proxy_enabled        = true
}

module "bastion" {
  source              = "../../modules/bastion"
  project             = var.project
  env                 = var.env
  location            = var.location
  vnet_id             = module.network.vnet_id
  bastion_subnet_id   = module.network.bastion_subnet_id
}

module "jumpbox" {
  source           = "../../modules/vm_jumpbox"
  project          = var.project
  env              = var.env
  location         = var.location
  subnet_id        = module.network.jumpbox_subnet_id
  admin_username   = "azureuser"
}

module "gh_runner" {
  source         = "../../modules/gh_runner_vm"
  project        = var.project
  env            = var.env
  location       = var.location
  subnet_id      = module.network.management_subnet_id
  admin_username = "azureuser"
  labels         = ["aaimacdl","prod"]
}

module "logs" {
  source   = "../../modules/log_analytics"
  project  = var.project
  env      = var.env
  location = var.location
  retention_days = 90
}

module "key_vault" {
  source           = "../../modules/key_vault"
  project          = var.project
  env              = var.env
  location         = var.location
  vnet_id          = module.network.vnet_id
  private_subnet_id= module.network.private_endpoints_subnet_id
  admin_object_id  = var.admin_object_id
  kv_private_dns_zone_id = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]
}
module "service_bus" {
  source                 = "../../modules/service_bus"
  project                = var.project
  env                    = var.env
  location               = var.location
  vnet_id                = module.network.vnet_id
  private_subnet_id      = module.network.private_endpoints_subnet_id
  log_analytics_id       = module.logs.law_id
  sb_private_dns_zone_id = module.private_dns.zone_ids["privatelink.servicebus.windows.net"]
}
module "function_app" {
  source                           = "../../modules/function_app"
  project                          = var.project
  env                              = var.env
  location                         = var.location
  vnet_id                          = module.network.vnet_id
  integration_subnet_id            = module.network.func_integration_subnet_id
  private_endpoints_subnet_id      = module.network.private_endpoints_subnet_id
  log_analytics_id                 = module.logs.law_id
  service_bus_namespace_id         = module.service_bus.namespace_id
  service_bus_fqdn                 = module.service_bus.fqdn
  service_bus_queue_name           = module.service_bus.queue_name
  webapps_private_dns_zone_id      = module.private_dns.zone_ids["privatelink.azurewebsites.net"]
}

module "app_gateway" {
  source                      = "../../modules/app_gateway"
  project                     = var.project
  env                         = var.env
  location                    = var.location
  vnet_id                     = module.network.vnet_id
  subnet_id                   = module.network.appgw_subnet_id
  key_vault_secret_id         = module.key_vault.agw_cert_secret_id
  backend_fqdn                = module.function_app.default_hostname
  log_analytics_id            = module.logs.law_id
}

module "private_dns" {
  source                  = "../../modules/private_dns"
  project                 = var.project
  env                     = var.env
  vnet_id                 = module.network.vnet_id
  zone_names              = [
    "privatelink.vaultcore.azure.net",
    "privatelink.servicebus.windows.net",
    "privatelink.azurewebsites.net",
    "privatelink.blob.core.windows.net"
  ]
}