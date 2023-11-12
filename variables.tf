variable "master_application_client_id" {
    description ="Application ID of the master app used to create the resources on Entra."
    type = string
}

variable "master_application_client_secret" {
    description ="Application secret of the master app used to create the resources on Entra."
    type = string
}

variable "tenant_id" {
    description ="The ID of your Entra Tenant."
    type = string
}