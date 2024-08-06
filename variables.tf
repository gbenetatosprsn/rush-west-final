variable "tenant_id" {
  description = "(Required) Globaly Unique Identifier (GUID) for your Microsoft Tenant"
  type        = string
}

variable "subscription_id" {
  description = "(Required) Globaly Unique Identifier (GUID) for your Microsoft Subscription within a Tenant"
  type        = string
}

variable "client_id" {
  description = "(Required) Application ID used to associate your application with Azure AD at runtime"
  type        = string
}

variable "client_secret" {
  description = "(Required) Application secret used for the service principal (App registration)"
  type        = string
  sensitive   = true
}

variable "admin_username_networking" {
  description = "(Required) Virtual machine administrator username for network resources"
  type        = string
}

variable "admin_password_init" {
  description = "(Optional) Virtual machine administrator password used during bootstrap (unchanging). This is not needed if ssh_key_value_init is supplied"
  type        = string
  sensitive   = true
}
