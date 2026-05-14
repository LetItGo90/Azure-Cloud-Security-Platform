variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_hub_name" {
  type    = string
  default = "vnet-hub"
}
variable "hub_vnet_address_space" {
  type = list(string)
}

variable "hub_vnet_id" {
  type = string
}

variable "spoke_vnet_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "vnet_spoke_name" {
  type    = string
  default = "vnet-spoke"
}

variable "key_vault_id" {
  type = string
}

variable "spoke_subnet_id" {
  type = string
}