locals {
  login_callback_path = substr(var.login_callback_path, 0, 1) == "/" ? var.login_callback_path : "/${var.login_callback_path}"
  logout_callback_path = substr(var.logout_callback_path, 0, 1) == "/" ? var.logout_callback_path : "/${var.logout_callback_path}"
  login_callbacks = [for cp in var.allowed_origins : "${cp}${local.login_callback_path}"]
  logout_callbacks = [for cp in var.allowed_origins : "${cp}${local.logout_callback_path}"]
}

resource "auth0_client" "app" {
  name                       = var.app_name
  app_type                   = "spa"
  is_first_party             = true
  token_endpoint_auth_method = "none"
  oidc_conformant            = true
  callbacks                  = local.login_callbacks
  allowed_origins            = var.allowed_origins
  grant_types                = var.grant_types
  allowed_logout_urls        = local.logout_callbacks
  web_origins                = var.allowed_origins
  jwt_configuration {
    lifetime_in_seconds = var.jwt_lifetime_seconds
    secret_encoded      = var.jwt_secret_encoded
    alg                 = var.jwt_alg
  }
  refresh_token {
    rotation_type                = var.refresh_rotation_type
    expiration_type              = var.refresh_expiration_type
    leeway                       = var.refresh_leeway
    token_lifetime               = var.refresh_token_lifetime
    infinite_idle_token_lifetime = var.refresh_infinite_idle_token_lifetime
    infinite_token_lifetime      = var.refresh_infinite_token_lifetime
    idle_token_lifetime          = var.refresh_idle_token_lifetime
  }
}

resource "auth0_client_grant" "client_grant" {
  for_each = { for v in var.client_grants : v.audience => v.scopes }
  client_id = auth0_client.app.id
  audience  = each.key
  scope     = each.value
}
