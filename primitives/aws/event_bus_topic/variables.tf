variable "role_id" {
  type = string
}

variable "event_bus_name" {
  type = string
}

variable "event_source_name" {
  type = string
  description = "e.g. com.acme.customer-service"
}

variable "event_type" {
  type = string
  description = "com.acme.customers.CustomerEvent"
}
