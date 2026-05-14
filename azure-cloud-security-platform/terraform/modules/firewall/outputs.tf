output "firewall_private_ip" {
  value = azurerm_firewall.AZFW_VNet.ip_configuration[0].private_ip_address
}
