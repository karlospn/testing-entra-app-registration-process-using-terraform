resource "azuread_application" "frontend_spa_application" {   
    display_name     = "frontend-spa"
    owners           = [data.azuread_client_config.current.object_id]

    single_page_application {
        redirect_uris = ["https://oidcdebugger.com/debug"]
    }

    required_resource_access {
        resource_app_id = azuread_application.payments_api_application.client_id

        resource_access {
            id   = azuread_application.payments_api_application.oauth2_permission_scope_ids["payment.read"]
            type = "Scope"
        }
    }
}

resource "azuread_service_principal" "frontend_spa_sp" {
  client_id                    = azuread_application.frontend_spa_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  tags                         = ["frontend", "spa"]
}


resource "azuread_application_pre_authorized" "frontend_span_preauthorized" {
  application_id       = azuread_application.payments_api_application.id
  authorized_client_id = azuread_application.frontend_spa_application.client_id

  permission_ids = [
    random_uuid.payments_read_scope_id.result
  ]
}