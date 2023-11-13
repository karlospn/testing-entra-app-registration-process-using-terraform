resource "azuread_app_role_assignment" "jane_payments_api_role_assignment" {
  app_role_id         = azuread_application.payments_api_application.app_role_ids["Reader"]
  principal_object_id = data.azuread_user.jane_user.object_id
  resource_object_id  = azuread_service_principal.payments_sp.object_id
}

resource "azuread_app_role_assignment" "john_payments_api_role_assignment" {
  app_role_id         = azuread_application.payments_api_application.app_role_ids["Admin"]
  principal_object_id = data.azuread_user.john_user.object_id
  resource_object_id  = azuread_service_principal.payments_sp.object_id
}