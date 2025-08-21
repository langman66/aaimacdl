variable "project" {}
variable "env" {}
variable "location" {}
variable "subnet_id" {}
variable "admin_username" { default = "azureuser" }
variable "labels" {
	type    = list(string)
	default = ["aaimacdl"]
}
