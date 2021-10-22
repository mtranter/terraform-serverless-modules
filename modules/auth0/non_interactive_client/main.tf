resource "auth0_client" "app" {
  name                       = var.app_name
  app_type                   = "non_interactive"
  is_first_party             = true
  token_endpoint_auth_method = "client_secret_basic"
  oidc_conformant            = true
  grant_types                = ["client_credentials"]
  jwt_configuration {
    lifetime_in_seconds = var.jwt_lifetime_seconds
    secret_encoded      = var.jwt_secret_encoded
    alg                 = var.jwt_alg
  }
  refresh_token {
    rotation_type                = var.refresh_rotation_type
    expiration_type              = var.refresh_expiration_type
    leeway                       = var.refresh_leeway
    token_lifetime               = var.refresh_idle_token_lifetime
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