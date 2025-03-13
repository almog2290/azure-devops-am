terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.3"
    }
    time = {
      source = "hashicorp/time"
      version = "0.13.0"
    }
  }
}

provider "azurerm" {
  features {}
  # # Configure the Azure Provider with your credentials
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

provider "null" {
  # Configuration options
}

provider "time" {
  # Configuration options
}