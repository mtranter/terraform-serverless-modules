terraform {
  experiments = [
  module_variable_optional_attrs]
}

variable "environment_vars" {
  type        = map(string)
  default     = {}
  description = "The environment variables to set for the function"
}

variable "service_name" {
  type        = string
  description = "The name of the service to which this function belongs"
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-_]+$", var.service_name))
    error_message = "The service_name value must be a begin with a letter and contain only alphnumeric characters, - and_."
  }
}

variable "function_name" {
  type        = string
  description = "The name of the service to which this function belongs"
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-_]+$", var.function_name))
    error_message = "The function_name value must be a begin with a letter and contain only alphnumeric characters, - and_."
  }
}

variable "description" {
  type    = string
  default = null
}

variable "handler" {
  type        = string
  description = "The handler function"
}

variable "filename" {
  type        = string
  description = "The file containing the lambda code."
}

variable "timeout" {
  type    = number
  default = 3
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "layers" {
  type        = list(string)
  default     = []
  description = "A list of layer arns that the lambda function will use"
}

variable "runtime" {
  type    = string
  default = "nodejs14.x"
}

variable "publish" {
  type        = bool
  default     = true
  description = "Sets whether to publish creation/change as a new Lambda Function"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to add to the lambda"
}

variable "vpc_config" {
  type = object({
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default     = null
  description = "The config for the VPC to which this lambda is to be added. Defaults to null"
}

variable "xray_enabled" {
  default     = true
  type        = bool
  description = "Enable XRay for this function"
}

variable "file_system_config" {
  type = object({
    efs_access_point_arn = string
    local_mount_path     = string
  })
  default = null
}

variable "layers_source" {
  type        = map(string)
  description = "A map of layer name to layer source"
  default     = {}
}

variable "reserved_concurrency" {
  type    = number
  default = -1
}

variable "create_dlq" {
  type    = bool
  default = null
}

variable "triggers" {
  type = object({
    api = optional(map(object({
      rest_api_id = string
      resource_id = string
      methods     = set(string)
    })))
    sqs = optional(map(string))
    eventbridge = optional(map(object({
      event_bus_name = string
      detail_types = list(string)
    })))
  })
}

variable "give_access_to" {
  type    = set(string)
  default = []
}
