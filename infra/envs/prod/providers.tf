terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azapi = {
      source = "azure/azapi"
      version = "~> 1.13"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
