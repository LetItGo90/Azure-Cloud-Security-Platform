# modules/networking/outputs.tf

# Hub
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "firewall_subnet_id" {
  value = azurerm_subnet.AzureFirewallSubnet.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.AzureBastionSubnet.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.GatewaySubnet.id
}

# Spoke
output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "data_subnet_id" {
  value = azurerm_subnet.data.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app.id
}

output "data_nsg_id" {
  value = azurerm_network_security_group.data.id
}

output "pe_nsg_id" {
  value = azurerm_network_security_group.pe.id
}