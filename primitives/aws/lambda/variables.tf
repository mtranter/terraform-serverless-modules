variable "environment_vars" {
  type        = map(string)
  default     = {}
  description = "The environment variables to set for the function"
}

variable "name" {
  type        = string
  description = "The name of the function"
}

variable "description" {
  type = string
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
  type = string
}

variable "publish" {
  type        = bool
  description = "Sets whether to publish creation/change as a new Lambda Function"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to add to the lambda"
}

variable "vpc_config" {
  type = object({
    vpc_id = string
    subnet_ids = list(string)
    security_group_ids = list(string)
  })
  default = null
  description = "The config for the VPC to which this lambda is to be added. Defaults to null"
}

variable "xray_enabled" {
  default = true
  type = bool
  description = "Enable XRay for this function"
}

variable "file_system_config" {
  type = object({
    efs_access_point_arn = string
    local_mount_path = string
  })
  default = null
}

variable "reserved_concurrency" {
  type = number
  default = -1
}

variable "dlq_arn" {
  type = string
  default = null
}
