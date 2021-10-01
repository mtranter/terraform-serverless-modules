variable "api_gw_name" {
  type = string
}

variable "api_gw_description" {
  type = string
}

variable "health_check_response" {
  type    = any
  default = {
    status = "ok"
  }
}

variable "healthcheck_path" {
  default = "__healthcheck"
}

variable "default_stage_name" {
  type = string
}

variable "access_log_retention_days" {
  type = number
  default = 365
}

variable "enable_caching" {
  type = bool
  default = false
}

variable "cache_cluster_size" {
  type = number
  description = "Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237"
  default = null
}

variable "xray_enabled" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}
