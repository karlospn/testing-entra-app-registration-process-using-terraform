resource "random_uuid" "payments_write_scope_id" {}
resource "random_uuid" "payments_read_scope_id" {}
resource "random_uuid" "payments_admin_app_role_id" {}
resource "random_uuid" "payments_reader_app_role_id" {}

resource "azuread_application" "payments_api_application" {
    
    display_name     = "payments-api"
    identifier_uris  = ["api://payments"]
    owners           = [data.azuread_client_config.current.object_id]

    api {
        requested_access_token_version = 2

        oauth2_permission_scope {
            admin_consent_description  = "Allow the application to access the commit payment methods"
            admin_consent_display_name = "payment.write"
            enabled                    = true
            id                         = random_uuid.payments_write_scope_id.result
            type                       = "Admin"
            user_consent_description  = "Allow the application to access the commit payment methods"
            user_consent_display_name  = "payment.write"
            value                      = "payment.write"
        }

        oauth2_permission_scope {
            admin_consent_description  = "Allow the application to access the read payment methods"
            admin_consent_display_name = "payment.read"
            enabled                    = true
            id                         = random_uuid.payments_read_scope_id.result
            type                       = "User"
            user_consent_description   = "Allow the application to access the read payment methods"
            user_consent_display_name  = "payment.read"
            value                      = "payment.read"
        }
    }

    app_role {
        allowed_member_types = ["User", "Application"]
        description          = "Can read and make payments"
        display_name         = "Admin"
        enabled              = true
        id                   = random_uuid.payments_admin_app_role_id.result
        value                = "Admin"
    }

    app_role {
        allowed_member_types = ["User", "Application"]
        description          = "Can only read payments"
        display_name         = "Reader"
        enabled              = true
        id                   = random_uuid.payments_reader_app_role_id.result
        value                = "Reader"
    }
}

resource "azuread_service_principal" "payments_sp" {
  client_id                    = azuread_application.payments_api_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  tags                         = ["payments", "api"]
}