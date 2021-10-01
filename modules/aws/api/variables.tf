variable "api_gateway_name" {
  type = string
}

variable "api" {
  type = map(object({
    path    = string
    methods = set(string)
    root_resource_path = optional(string)
    authorization = optional(string)
    authorizer_id = optional(string)
    authorization_scopes = optional(string)
    enable_cors = optional(bool)
  }))
}
