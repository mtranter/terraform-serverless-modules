variable "name" {
  type = string
}

variable "hash_key" {
  type = object({
    name = string
    type = string
  })
}

variable "range_key" {
  type = object({
    name = string
    type = string
  })
  default = null
}

variable "stream_enabled" {
  type    = bool
  default = false
}

variable "stream_view_type" {
  type    = string
  default = "NEW_AND_OLD_IMAGES"
}

variable "provisioned_capacity" {
  type = object({
    read  = number
    write = number
  })
  default = null
}

variable "ttl_attribute" {
  default = null
  type    = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "point_in_time_recovery_enabled" {
  type    = bool
  default = false
}

variable "local_secondary_indexes" {
  default = []
  type = set(object({
    name = string
    range_key = optional(object({
      name = string
      type = string
    }))
    projection_type = optional(string)
    non_key_attributes = optional(list(string))
  }))
}

variable "global_secondary_indexes" {
  default = []
  type = set(object({
    name = string
    provisioned_capacity = optional(object({
      read  = number
      write = number
    }))
    hash_key = object({
      name = string
      type = string
    })
    range_key = optional(object({
      name = string
      type = string
    }))
    projection_type = optional(string)
    non_key_attributes = optional(list(string))
  }))
}
