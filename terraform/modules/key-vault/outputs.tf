output "key_vault_id" {
  value = azurerm_key_vault.vault.id
}

output "key_vault_key_id" {
  value = azurerm_key_vault_key.vault_key.id
}