variable "app_name" {
  type = string
}



variable "client_grants" {
  type = list(object({
    audience = string
    scopes = list(string)
  }))
}

variable "jwt_lifetime_seconds" {
  type = number
  default = 300
}

variable "jwt_secret_encoded" {
  type = bool
  default = false
}

variable "jwt_alg" {
  type = string
  default = "RS256"
}
variable refresh_rotation_type {
  type = string
  default = "rotating"
}
variable refresh_expiration_type {
  type = string
  default = "expiring"
}
variable refresh_leeway {
  type = number
  default = 15
}
variable refresh_token_lifetime {
  type = number
  default = 84600
}
variable refresh_infinite_idle_token_lifetime {
  type = bool
  default = false
}
variable refresh_infinite_token_lifetime {
  type = bool
  default = false
}
variable refresh_idle_token_lifetime {
  type = number
  default = 3600
}