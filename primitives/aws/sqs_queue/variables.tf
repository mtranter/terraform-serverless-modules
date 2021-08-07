variable "queue_name" {
  type        = string
  description = "Queue name"
}

variable "create_dlq" {
  type = bool
  default = false
}

variable "tags" {
  type = map(string)
}

variable "delay_seconds" {
  description = "The queue delay seconds. Default 0"
  default     = 0
  type        = number
}

variable "message_retention_seconds" {
  type    = number
  default = 1209600
}

variable "visibility_timeout_seconds" {
  default = 30
  type    = number
}

variable "is_fifo" {
  default = false
  type = bool
}

variable "allow_sns" {
  type = bool
  default = false
}

variable "content_based_deduplication" {
  type = bool
  default = null
}


variable "deduplication_scope" {
  type = string
  default = null
  validation {
    condition     = var.deduplication_scope == null || var.deduplication_scope == "messageGroup" || var.deduplication_scope == "queue"
    error_message = "The deduplication_scope value must be either messageGroup or queue."
  }
}

variable "fifo_throughput_limit" {
  type = string
  default = null
  validation {
    condition     = var.fifo_throughput_limit == null || var.fifo_throughput_limit == "perMessageGroupId" || var.fifo_throughput_limit == "perQueue"
    error_message = "The deduplication_scope value must be either perMessageGroupId or perQueue."
  }
}