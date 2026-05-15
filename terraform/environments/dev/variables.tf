variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type    = string
  default = "rg-azure-vuln-platform-dev"
}

variable "location" {
  type    = string
  default = "westcentralus"
}

variable "allowed_source_addresses" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "hub_vnet_address_space" {
  type = list(string)
}

variable "app_subnet_prefix" {
  type = string
}

variable "data_subnet_prefix" {
  type = string
}

variable "pe_subnet_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}