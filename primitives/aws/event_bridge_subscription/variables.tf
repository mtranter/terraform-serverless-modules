variable "event_bus_name" {
  type = string
}

variable "subscription_name" {
  type = string
}

variable "detail_types" {
  type = list(string)
}

variable "target_arn" {
  type = string
}