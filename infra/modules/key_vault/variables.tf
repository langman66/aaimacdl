variable "project" {}
variable "env" {}
variable "location" {}
variable "vnet_id" {}
variable "private_subnet_id" {}
variable "admin_object_id" {}
variable "tenant_id" { default = null }
# Supply a Private DNS zone id for privatelink.vaultcore.azure.net from module.private_dns
variable "kv_private_dns_zone_id" {
	type    = string
	default = null
}
