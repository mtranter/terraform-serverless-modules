resource "auth0_resource_server" "api" {
  name        = var.server_name
  identifier  = var.audience_name
  signing_alg = var.signing_alg

  dynamic scopes {
    for_each = var.scopes
    content {
      value       = scopes.value.value
      description = scopes.value.description
    }
  }

  allow_offline_access                            = var.allow_offline_access
  token_lifetime                                  = var.token_lifetime
  skip_consent_for_verifiable_first_party_clients = var.skip_consent_for_verifiable_first_party_clients
}