output "github_actions_client_id" {
  value = azurerm_user_assigned_identity.github_actions.client_id
}

output "github_actions_principal_id" {
  value = azurerm_user_assigned_identity.github_actions.principal_id
}

output "workload_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "workload_principal_id" {
  value = azurerm_user_assigned_identity.workload.principal_id
}

output "workload_identity_id" {
  value = azurerm_user_assigned_identity.workload.id
}