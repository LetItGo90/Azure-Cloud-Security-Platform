# modules/networking/variables.tf

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "firewall_subnet_prefix" {
  type    = string
  default = "10.0.0.0/26" # /26 minimum — Azure enforces this
}

variable "bastion_subnet_prefix" {
  type    = string
  default = "10.0.1.0/26"
}

variable "gateway_subnet_prefix" {
  type    = string
  default = "10.0.2.0/27"
}

variable "management_subnet_prefix" {
  type    = string
  default = "10.0.3.0/24"
}


variable "spoke_vnet_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "app_subnet_prefix" {
  type    = string
  default = "10.1.0.0/24"
}

variable "data_subnet_prefix" {
  type    = string
  default = "10.1.1.0/24"
}

variable "pe_subnet_prefix" {
  type    = string
  default = "10.1.2.0/24"
}

variable "firewall_private_ip" {
  type = string
}

variable "vnet_hub_name" {
  type    = string
  default = "vnet-hub"
}
variable "hub_vnet_address_space" {
  type = list(string)
}
variable "vnet_spoke_name" {
  type    = string
  default = "vnet-spoke"
}