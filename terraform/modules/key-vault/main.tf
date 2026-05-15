data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  name                        = "vault-keyrotation2026"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  rbac_authorization_enabled  = true
  sku_name                    = "standard"
  public_network_access_enabled = false
}

resource "azurerm_role_assignment" "key_vault_secret_officer" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.workload_principal_id
}

resource "azurerm_role_assignment" "terraform_kv_admin" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_for_rbac" {
  create_duration = "90s"

  depends_on = [
    azurerm_role_assignment.key_vault_secret_officer,
    azurerm_role_assignment.terraform_kv_admin,
  ]
}

resource "azurerm_key_vault_secret" "vaultsecret" {
  name            = "vaultsecret"
  value           = "ThisIsASecretValue"
  key_vault_id    = azurerm_key_vault.vault.id
  expiration_date = "2026-06-04T23:59:59Z"
  content_type    = "text/plain"

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostics" {
  name                       = "key-vault-diagnostics"
  target_resource_id         = azurerm_key_vault.vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }
}

output "secret_value" {
  value     = azurerm_key_vault_secret.vaultsecret.value
  sensitive = true
}


resource "azurerm_key_vault_key" "vault_key" {
  name         = "key-vault-certificate"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_role_assignment" "vault-key-crypto-user-role" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = var.workload_principal_id  
}