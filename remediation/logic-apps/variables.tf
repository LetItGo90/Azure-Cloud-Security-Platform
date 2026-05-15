variable "resource_group_name" {
  type    = string
  default = "rg-azure-vuln-platform-dev"
}

variable "location" {
  type    = string
  default = "westcentralus"
}


variable "log_analytics_workspace_name" {
  type        = string

}

variable "tags" {
  type    = map(string)
  default = {}
}


variable "storage_account_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}
