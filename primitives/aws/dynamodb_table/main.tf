terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  key_attributes = [
    for k in [var.hash_key, var.range_key] : {
      name = k.name
      type = k.type
    } if k != null
  ]
  gsi_attributes = flatten([
    for gi in var.global_secondary_indexes : [
      for k in [gi.hash_key, gi.range_key] : {
        name = k.name
        type = k.type
      } if k != null
    ]
    ]
  )
  lsi_attributes = flatten([
    for li in var.local_secondary_indexes : [{
      name = li.range_key.name
      type = li.range_key.type
    }]
  ])

  lsi_map = {
    for k in var.local_secondary_indexes: k.name => k
  }

  gsi_map = {
    for k in var.global_secondary_indexes: k.name => k
  }

  attributes = { for a in toset(concat(local.key_attributes, local.gsi_attributes, local.lsi_attributes)) : a.name => a.type }
}

resource "aws_dynamodb_table" "table" {
  hash_key       = var.hash_key.name
  range_key      = var.range_key == null ? null : var.range_key.name
  name           = var.name
  read_capacity  = var.provisioned_capacity == null ? null : var.provisioned_capacity.read
  write_capacity = var.provisioned_capacity == null ? null : var.provisioned_capacity.write
  billing_mode   = var.provisioned_capacity == null ? "PAY_PER_REQUEST" : "PROVISIONED"
  tags           = var.tags

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.key.arn
  }

  dynamic "global_secondary_index" {
    for_each = local.gsi_map
    iterator = each
    content {
      name               = each.value.name
      write_capacity     = each.value.provisioned_capacity == null ? null : each.value.provisioned_capacity.write
      read_capacity      = each.value.provisioned_capacity == null ? null : each.value.provisioned_capacity.read
      hash_key           = each.value.hash_key.name
      range_key          = each.value.range_key.name
      projection_type    = coalesce(each.value.projection_type, "ALL")
      non_key_attributes = each.value.non_key_attributes == null ? [] : each.value.non_key_attributes
    }
  }

  dynamic "local_secondary_index" {
    for_each = local.lsi_map
    iterator = each
    content {
      name               = each.value.name
      range_key          = each.value.range_key.name
      projection_type    = coalesce(each.value.projection_type, "ALL")
      non_key_attributes = each.value.non_key_attributes == null ? [] : each.value.non_key_attributes
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute == null ? [] : [1]

    content {
      attribute_name = var.ttl_attribute
      enabled        = var.ttl_attribute != null
    }
  }

  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }
}
