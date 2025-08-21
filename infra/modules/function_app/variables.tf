variable "project" {}
variable "env" {}
variable "location" {}
variable "vnet_id" {}
variable "integration_subnet_id" {}
variable "private_endpoints_subnet_id" {}
variable "log_analytics_id" {}
variable "service_bus_namespace_id" {}
variable "service_bus_fqdn" {}
variable "service_bus_queue_name" {}
# provide zone id for privatelink.azurewebsites.net
variable "webapps_private_dns_zone_id" {
	type    = string
	default = null
}
