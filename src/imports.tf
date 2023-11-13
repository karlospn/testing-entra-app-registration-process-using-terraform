data "azuread_client_config" "current" {}

data "azuread_user" "jane_user" {
  user_principal_name = "jane@carlosponsnoutlook.onmicrosoft.com"
}

data "azuread_user" "john_user" {
  user_principal_name = "john@carlosponsnoutlook.onmicrosoft.com"
}