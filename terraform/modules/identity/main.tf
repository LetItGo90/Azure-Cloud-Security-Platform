# --- GitHub Actions Identity ---
resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "mi-github-actions"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "github_actions_pr" {
  name                = "github-pr-workflow"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.github_actions.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:LetItGo90/Azure-Cloud-Security-Platform:pull_request"
}

resource "azurerm_federated_identity_credential" "github_actions_main" {
  name                = "github-main-workflow"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.github_actions.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:LetItGo90/Azure-Cloud-Security-Platform:ref:refs/heads/main"
}

# --- Workload Identity ---
resource "azurerm_user_assigned_identity" "workload" {
  name                = "mi-workload"
  resource_group_name = var.resource_group_name
  location            = var.location
}