variable "project" {}
variable "env" {}
variable "location" {}
variable "vnet_id" {}
variable "firewall_subnet_id" {}
variable "firewall_mgmt_subnet_id" {}
variable "dns_proxy_enabled" {
	type    = bool
	default = true
}
