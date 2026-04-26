variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "hrw-demo-rg"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "eastus"
}

variable "tenant_id" {
  description = "Entra ID Tenant ID — used for Key Vault access policies"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to every resource for cost tracking and ownership"
  type        = map(string)
  default = {
    environment = "demo"
    project     = "hrw-azure-demo"
    owner       = "kennedy.korir"
    managed_by  = "terraform"
    purpose     = "interview-demo"
  }
}