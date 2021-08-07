locals {
  lifecycle_transitions = { for o in var.lifecycle_transitions : o.id => o }
}

terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  acl    = "private"

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = local.lifecycle_transitions
    iterator = each
    content {
      enabled                                = true
      id                                     = each.value.id
      prefix                                 = each.value.prefix
      tags                                   = each.value.tags
      abort_incomplete_multipart_upload_days = each.value.abort_incomplete_multipart_upload_days
      dynamic "expiration" {
        for_each = each.value.expiration == null ? [] : [1]
        content {
          date                         = each.value.expiration.date
          days                         = each.value.expiration.days
          expired_object_delete_marker = each.value.expiration.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = each.value.transition == null ? [] : [1]
        content {
          date          = each.value.transition.date
          days          = each.value.transition.days
          storage_class = each.value.transition.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = each.value.noncurrent_version_expiration == null ? [] : [1]
        content {
          days = each.value.noncurrent_version_expiration.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = each.value.noncurrent_version_transition == null ? [] : [1]
        content {
          days          = each.value.noncurrent_version_transition.days
          storage_class = each.value.noncurrent_version_transition.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket              = aws_s3_bucket.bucket.id
  block_public_acls   = true
  block_public_policy = true
}
