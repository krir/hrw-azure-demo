output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.hrw.name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.hrw.name
}

output "key_vault_uri" {
  description = "URI for accessing the Key Vault"
  value       = azurerm_key_vault.hrw.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.hrw.workspace_id
}

output "recovery_vault_name" {
  description = "Recovery Services Vault name"
  value       = azurerm_recovery_services_vault.hrw.name
}

output "vnet_id" {
  description = "Virtual Network ID from networking module"
  value       = module.networking.vnet_id
}