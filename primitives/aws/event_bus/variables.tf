variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "archive" {
  type    = bool
  default = true
}