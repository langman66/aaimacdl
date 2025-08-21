variable "project" {}
variable "env" {}
variable "location" {}
variable "vnet_id" {}
variable "private_subnet_id" {}
variable "log_analytics_id" {}
# provide zone id for privatelink.servicebus.windows.net
variable "sb_private_dns_zone_id" {
	type    = string
	default = null
}
