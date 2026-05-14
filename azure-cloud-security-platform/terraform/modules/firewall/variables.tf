variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "firewall_subnet_id" {
  type = string
}

variable "allowed_source_addresses" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "public_ip_name" {
  type    = string
  default = "fw-public-ip"
}

variable "firewall_policy_name" {
  type    = string
  default = "firewall-policy"
}

variable "firewall_vnet_name" {
  type    = string
  default = "AZFW_VNet"
}