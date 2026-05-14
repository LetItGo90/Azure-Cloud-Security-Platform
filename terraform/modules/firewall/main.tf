resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns {proxy_enabled = true}
  sku = "Standard"
}

resource "azurerm_firewall" "AZFW_VNet" {
  name                = var.firewall_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id

 
  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

# --- Firewall Policy Rules ---

resource "azurerm_firewall_policy_rule_collection_group" "default" {
  name               = "default-rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 300

  network_rule_collection {
    name     = "allow-dns-https"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "allow-dns-https"
      protocols             = ["TCP", "UDP"]
      source_addresses      = var.allowed_source_addresses
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
  }
}



# --- Diagnostics Settings ---
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "fw-diagnostics"
  target_resource_id         = azurerm_firewall.AZFW_VNet.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}