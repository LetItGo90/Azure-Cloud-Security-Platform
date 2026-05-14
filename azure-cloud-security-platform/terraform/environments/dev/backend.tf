terraform {
  backend "azurerm" {
    resource_group_name  = "rg-azure-vuln-platform-dev"
    storage_account_name = "utfstateazurevulnplatdev"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
    use_azuread_auth     = true
  }
}