terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
  # Remote state in Azure Blob Storage
  # Shared, locked — not stuck on your laptop
  backend "azurerm" {
    resource_group_name  = "hrw-tfstate-rg"
    storage_account_name = "hrwtfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# JD #1: Design and Administration — Resource Group
resource "azurerm_resource_group" "hrw" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# JD #11: Identity — Key Vault stores secrets safely
# Secrets NEVER go in code, YAML, or committed tfvars
resource "azurerm_key_vault" "hrw" {
  name                       = "hrw-keyvault-demo"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.hrw.name
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# JD #7: Networking — VNet, Subnet, NSG via reusable module
module "networking" {
  source              = "../modules/networking"
  resource_group_name = azurerm_resource_group.hrw.name
  location            = var.location
  tags                = var.tags
}

# JD #12: Application Monitoring — Log Analytics Workspace
# All Azure Monitor alerts and Defender logs feed here
resource "azurerm_log_analytics_workspace" "hrw" {
  name                = "hrw-logs-workspace"
  location            = var.location
  resource_group_name = azurerm_resource_group.hrw.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# JD #13: Backup Review — Recovery Services Vault
resource "azurerm_recovery_services_vault" "hrw" {
  name                = "hrw-rsv-demo"
  location            = var.location
  resource_group_name = azurerm_resource_group.hrw.name
  sku                 = "Standard"
  soft_delete_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}