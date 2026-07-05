terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # any 4.x, never 5.x — protects against breaking changes
    }
  }
}

provider "azurerm" {
  features {} # required, even when empty

  # Register only the providers this project uses (done manually via az CLI)
  resource_provider_registrations = "none"

  # Auth comes from the 'az login' session — no credentials in code
  subscription_id = var.subscription_id
}
