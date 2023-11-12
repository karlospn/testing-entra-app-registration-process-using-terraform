output "bookings_api_application_secret" {
  description = "Password associated with the Bookings API application."
  value       = azuread_application_password.bookings_api_pwd.value
  sensitive   = true
}