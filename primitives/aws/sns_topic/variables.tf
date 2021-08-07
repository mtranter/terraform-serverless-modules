variable "topic_name" {
  type = string
}

variable "is_fifo" {
    type = bool
}

variable "content_based_deduplication" {
  type = bool
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}