locals {
  function_name = "${var.service_name}-${var.function_name}"
  is_async = length(coalesce(var.triggers["eventbridge"], var.triggers["sqs"], tomap({}))) > 0
}

resource "aws_lambda_alias" "live_alias" {
  function_name    = module.lambda.function.function_name
  function_version = module.lambda.function.version
  name             = "live"
}

module "lambda" {
  source               = "./../../modules/lambda"
  create_dlq           = coalesce(var.create_dlq, local.is_async)
  keep_warm            = length(coalesce(var.triggers["api"], tomap({}))) > 0
  filename             = var.filename
  handler              = var.handler
  name                 = local.function_name
  publish              = var.publish
  runtime              = var.runtime
  tags                 = var.tags
  description          = var.description
  environment_vars     = merge({
    ServiceName = var.service_name
  }, var.environment_vars)
  timeout              = var.timeout
  layers               = var.layers
  layers_source        = var.layers_source
  memory_size          = var.memory_size
  vpc_config           = var.vpc_config
  xray_enabled         = var.xray_enabled
  reserved_concurrency = var.reserved_concurrency
  file_system_config   = var.file_system_config
}