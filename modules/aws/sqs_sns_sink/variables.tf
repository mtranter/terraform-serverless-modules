variable "queue_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sns_topic_arn" {
  type = string
}

variable "is_fifo" {
  type = bool
}

variable "create_dlq" {
  type = bool
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "content_based_deduplication" {
  type    = bool
  default = null
}

variable "filter_policy" {
  type = map(any)
  default = null
}
variable "deduplication_scope" {
  type    = string
  default = null
  validation {
    condition     = var.deduplication_scope == null || var.deduplication_scope == "messageGroup" || var.deduplication_scope == "queue"
    error_message = "The deduplication_scope value must be either messageGroup or queue."
  }
}

variable "fifo_throughput_limit" {
  type    = string
  default = null
  validation {
    condition     = var.fifo_throughput_limit == null || var.fifo_throughput_limit == "perMessageGroupId" || var.fifo_throughput_limit == "perQueue"
    error_message = "The deduplication_scope value must be either perMessageGroupId or perQueue."
  }
}
