resource "aws_lambda_event_source_mapping" "sqs_source" {
  depends_on = [aws_iam_role_policy.sqs_source_permissions]
  for_each         = { for k, arn in coalesce(var.triggers["sqs"], tomap({})) : k => arn }
  event_source_arn = each.value
  function_name    = module.lambda.function.arn
  enabled          = true
  batch_size       = 1
}

data "aws_iam_policy_document" "sqs_lambda_permissions" {
  count = length(keys(coalesce(var.triggers["sqs"], tomap({}))))

  dynamic "statement" {
    for_each = { for k, arn in coalesce(var.triggers["sqs"], tomap({})) : k => arn }
    iterator = each
    content {
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      effect    = "Allow"
      resources = [each.value]
    }
  }
}

resource "aws_iam_role_policy" "sqs_source_permissions" {
  count  = length(keys(coalesce(var.triggers["sqs"], tomap({}))))
  name   = "${local.function_name}SQSSourceAccess"
  policy = data.aws_iam_policy_document.sqs_lambda_permissions[0].json
  role   = module.lambda.execution_role.id
}
