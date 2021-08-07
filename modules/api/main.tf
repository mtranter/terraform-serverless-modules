locals {
  null_route = { path = null, parent = null }
  api = merge([for k, v in {for k, u in var.api : k => split("/", trim(u.path, "/"))} : {
    for i, p in v : join("/", slice(v, 0, i + 1)) => { path = p, parent = i > 0 ? join("/", slice(v, 0, i)) : null, name = k }
    }]...
  )
  methods = flatten([
    for k, p in var.api : [
      for m in p.methods : {
        name = k
        path = p.path
        method = m
        authorization = p.authorization
        authorizer_id = p.authorizer_id
        authorization_scopes = p.authorization_scopes
      }
  ]])
}

data "aws_api_gateway_rest_api" "api" {
  name = var.api_gateway_name
}

data "aws_api_gateway_resource" "root_resources" {
  for_each = {for k, v in var.api : k => coalesce(v.root_resource_path, "/") }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  path        = each.value
}

resource "aws_api_gateway_resource" "root_resources" {

  for_each    = { for k, v in local.api : k => v if v.parent == null }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = data.aws_api_gateway_resource.root_resources[each.value.name].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l1_resources" {
  for_each = { for k, v in local.api : k => v
    if v.parent != null
  && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent == null }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.root_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l2_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l1_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l3_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l2_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l4_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l3_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l5_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l4_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l6_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(
              lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
            ), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l5_resources[each.value.parent].id
  path_part   = each.value.path
}
resource "aws_api_gateway_resource" "l7_resources" {
  for_each = {
    for k, v in local.api : k => v
    if v.parent != null
    && lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    && lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(
              lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
            ), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent != null
    &&
    lookup(local.api, coalesce(
      lookup(local.api, coalesce(
        lookup(local.api, coalesce(
          lookup(local.api, coalesce(
            lookup(local.api, coalesce(
              lookup(local.api, coalesce(
                lookup(local.api, coalesce(v.parent, "@@"), local.null_route).parent, "@@"
              ), local.null_route).parent, "@@"
            ), local.null_route).parent, "@@"
          ), local.null_route).parent, "@@"
        ), local.null_route).parent, "@@"
      ), local.null_route).parent, "@@"
    ), local.null_route).parent == null
  }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.l6_resources[each.value.parent].id
  path_part   = each.value.path
}

data "aws_api_gateway_resource" "resources" {
  for_each    = { for k,v in var.api : k => v.path }
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  path        = each.value
  depends_on  = [
      aws_api_gateway_resource.root_resources,
      aws_api_gateway_resource.l1_resources,
      aws_api_gateway_resource.l2_resources,
      aws_api_gateway_resource.l3_resources,
      aws_api_gateway_resource.l4_resources,
      aws_api_gateway_resource.l5_resources,
      aws_api_gateway_resource.l6_resources,
      aws_api_gateway_resource.l7_resources
    ]
}

resource "aws_api_gateway_method" "method" {
  for_each      = { for x in local.methods : "${x.path}.${x.method}" => x }
  rest_api_id   = data.aws_api_gateway_rest_api.api.id
  resource_id   = data.aws_api_gateway_resource.resources[each.value.name].id
  http_method   = upper(each.value.method)
  authorization = coalesce(each.value.authorization, "NONE")
  authorizer_id = each.value.authorizer_id
}

module "example_cors" {
  for_each = {for k, v in var.api : k => v if v.enable_cors == true }
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"

  api      = data.aws_api_gateway_rest_api.api.id
  resource = data.aws_api_gateway_resource.resources[each.key].id

  methods = ["GET", "POST", "PUT", "DELETE"]
}


terraform {
  experiments = [module_variable_optional_attrs]
}
