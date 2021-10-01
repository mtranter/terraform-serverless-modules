variable "server_name" {
  type = string
  description = "Name of this resource server/api"
}

variable "audience_name" {
  type = string
}

variable "signing_alg" {
  type = string
  default = "RS256"
}

variable "scopes" {
  default = []
  type = set(object({
    value = string
    description = string
  }))
}

variable "allow_offline_access" {
  type = bool
}

variable "token_lifetime" {
  type = number
}

variable "skip_consent_for_verifiable_first_party_clients" {
  type = bool
}