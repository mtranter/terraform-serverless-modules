variable "subscription_name" {
  type = string
}

variable "event_bus_name" {
  type = string
}

variable "detail_types" {
  type = list(string)
}

variable "lambda_arn" {
  type = string
}