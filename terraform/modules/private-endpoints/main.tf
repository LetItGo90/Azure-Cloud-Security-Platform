
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "hub_network_link" {
  name                  = "hub-network-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = var.hub_vnet_id
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.spoke_subnet_id

  private_service_connection {
    name                           = "keyvault-privateserviceconnection"
    private_connection_resource_id = var.key_vault_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }
}