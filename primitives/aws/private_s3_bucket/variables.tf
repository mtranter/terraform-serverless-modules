variable "bucket" {
  type = string
}

variable "versioning_enabled" {
  type = bool
}

variable "access_logs" {
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null
}

variable "lifecycle_transitions" {
  type = set(object({
    id                                     = string
    prefix                                 = optional(string)
    tags                                   = optional(map(string))
    abort_incomplete_multipart_upload_days = optional(bool)
    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(string)
    }))
    transition = optional(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    }))
    noncurrent_version_expiration = optional(object({
      days = number
    }))
    noncurrent_version_transition = optional(object({
      days          = number
      storage_class = string
    }))
  }))
}
