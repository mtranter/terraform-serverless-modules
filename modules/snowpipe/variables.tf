variable "job_name" {
  type = string
}

variable "bucket_path" {
  type    = string
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

