locals {
  lambda_insights_extension_layer = "arn:aws:lambda:${data.aws_region.current.name}:580247275435:layer:LambdaInsightsExtension:14"
}

data "aws_region" "current" {}

module "log_group" {
  source = "./../../../primitives/aws/log_group"
  name   = "/aws/lambda/${var.name}"
}

data "aws_iam_policy_document" "can_log" {
  statement {
    sid = "CanLog"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      module.log_group.log_group.arn,
      "${module.log_group.log_group.arn}:*"
    ]
  }
}

module "dlq" {
  count      = var.create_dlq == true ? 1 : 0
  source     = "./../../../primitives/aws/sqs_queue"
  create_dlq = false
  queue_name = "${var.name}_dlq"
  tags       = var.tags
  is_fifo    = false
}

data "aws_iam_policy_document" "can_sqs_dlq" {
  count = var.create_dlq == true ? 1 : 0
  statement {
    sid = "CanSQSDLQ"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
    module.dlq[count.index].queue.arn]
  }
}

resource "aws_lambda_layer_version" "layers" {
  for_each            = var.layers_source
  layer_name          = each.key
  source_code_hash    = filebase64sha256(each.value)
  filename            = each.value
  compatible_runtimes = [var.runtime]
}

module "function" {
  source           = "./../../../primitives/aws/lambda"
  filename         = var.filename
  handler          = var.handler
  name             = var.name
  publish          = var.publish
  runtime          = var.runtime
  vpc_config       = var.vpc_config
  dlq_arn          = var.create_dlq == true ? module.dlq[0].queue.arn : null
  xray_enabled     = var.xray_enabled
  environment_vars = var.environment_vars
  tags             = var.tags
  layers = concat(var.layers, [
  local.lambda_insights_extension_layer], [for a in aws_lambda_layer_version.layers : a.arn])
  file_system_config   = var.file_system_config
  reserved_concurrency = var.reserved_concurrency
  memory_size          = var.memory_size
  timeout              = var.timeout
}

module "errors_alarm" {

  count = var.create_error_alarm ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 2.0"

  alarm_name          = "lambda-errors-${module.function.function.function_name}"
  alarm_description   = "Lambda function ${module.function.function.function_name} has raised an error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 60
  unit                = "Count"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  statistic   = "Maximum"

  dimensions = {
    FunctionName = module.function.function.function_name
  }

  alarm_actions = var.alarm_sns_topic_arn == null ? [] : [var.alarm_sns_topic_arn]
}


resource "aws_iam_role_policy" "dlq_role" {
  count  = var.create_dlq == true ? 1 : 0
  name   = "${var.name}DLQ"
  role   = module.function.execution_role.id
  policy = data.aws_iam_policy_document.can_sqs_dlq[0].json
}

resource "aws_iam_role_policy_attachment" "iam_for_lambda_role_eni" {
  count      = var.vpc_config == null ? 0 : 1
  role       = module.function.execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "aws_xray_write_only_access" {
  count      = var.xray_enabled == null ? 0 : 1
  role       = module.function.execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  role       = module.function.execution_role.id
}

resource "aws_iam_role_policy" "can_log" {
  policy = data.aws_iam_policy_document.can_log.json
  role   = module.function.execution_role.id
}
