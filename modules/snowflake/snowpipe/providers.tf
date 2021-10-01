terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    snowflake = {
      source = "chanzuckerberg/snowflake"
      version = "~> 0.25.15"
    }
  }
}