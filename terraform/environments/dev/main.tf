resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "monitoring" {
  source              = "../../modules/monitoring/"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

module "networking" {
  source                 = "../../modules/networking/"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  hub_vnet_address_space = var.hub_vnet_address_space
  app_subnet_prefix      = var.app_subnet_prefix
  data_subnet_prefix     = var.data_subnet_prefix
  pe_subnet_prefix       = var.pe_subnet_prefix
  firewall_private_ip    = module.firewall.firewall_private_ip
}

module "firewall" {
  source                     = "../../modules/firewall/"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = module.monitoring.workspace_id
  firewall_subnet_id         = module.networking.firewall_subnet_id
  allowed_source_addresses   = var.allowed_source_addresses
}

module "identity" {
  source              = "../../modules/identity/"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

module "key_vault" {
  source                      = "../../modules/key-vault/"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  log_analytics_workspace_id  = module.monitoring.workspace_id
  github_actions_principal_id = module.identity.github_actions_principal_id
  workload_principal_id       = module.identity.workload_principal_id
}

module "private_endpoints" {
  source              = "../../modules/private-endpoints/"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  hub_vnet_id         = module.networking.hub_vnet_id
  spoke_subnet_id     = module.networking.pe_subnet_id
  key_vault_id        = module.key_vault.key_vault_id
}

module "storage" {
  source                    = "../../modules/storage/"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  key_vault_key_id          = module.key_vault.key_vault_key_id
  user_assigned_identity_id = module.identity.workload_identity_id
  depends_on                = [module.key_vault, module.identity]
}

module "remediation" {
  source                       = "../../../remediation/logic-apps"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  log_analytics_workspace_name = module.monitoring.log_analytics_workspace_name
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  storage_account_name         = module.storage.storage_account_name
  tags                         = var.tags
}