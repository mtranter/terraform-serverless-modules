variable "publisher_role_id" {
  type = string
}

variable "event_bus_arn" {
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


variable "stream_name" {
  type = string
}

variable "bucket_path" {
  type = string
  default = ""
}

variable "bucket_name" {
  type = string
}

variable "bucket_region" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "stage_database" {
  type = string
}

variable "stage_schema" {
  type = string
}

variable "pipe_name" {
  type = string
}

variable "pipe_database" {
  type = string
}

variable "pipe_schema" {
  type = string
}

variable "file_format" {
  type = string
}

variable "copy_statement" {
  type = string
}

