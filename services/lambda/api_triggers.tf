resource "aws_api_gateway_integration" "integration" {
  for_each                = {for x in flatten([
  for k, v in coalesce(var.triggers["api"], tomap({})) : [
  for method in v.methods : {
    id          = "${k}.${method}"
    method      = method
    resource_id = v.resource_id
    rest_api_id = v.rest_api_id
  }]
  ]) :  x.id => x}
  http_method             = upper(each.value.method)
  resource_id             = each.value.resource_id
  rest_api_id             = each.value.rest_api_id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_alias.live_alias.invoke_arn
}

module "deployment" {
  for_each     = toset([for k, v in coalesce(var.triggers["api"], tomap({})) : v.rest_api_id])
  source       = "./../../modules/api_gateway_deployment"
  rest_api_id  = each.value
  service_name = var.service_name
  stage_name   = "live"
  trigger      = base64sha256(jsonencode(aws_api_gateway_integration.integration))
}

data "aws_region" "current" {}
data "aws_caller_identity" "me" {}

resource "aws_lambda_permission" "lambda_permission" {
  for_each      = toset([for k, v in coalesce(var.triggers["api"], tomap({})) : v.rest_api_id])
  statement_id  = "AllowApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  qualifier     = aws_lambda_alias.live_alias.name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:${each.value}/*/*/*"
}