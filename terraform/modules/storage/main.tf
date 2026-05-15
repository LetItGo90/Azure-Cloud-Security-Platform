resource "azurerm_storage_account" "storage" {
  name                     = "storageaccount123131"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}
resource "azurerm_storage_account_customer_managed_key" "managed_key" {
  storage_account_id        = azurerm_storage_account.storage.id
  key_vault_key_id          = var.key_vault_key_id
  user_assigned_identity_id = var.user_assigned_identity_id
}