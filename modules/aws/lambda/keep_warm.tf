
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  count               = var.keep_warm ? 1 : 0
  name                = "${var.name}-every-five-minutes"
  description         = "Fires function: ${var.name} every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_every_five_minutes" {
  count     = var.keep_warm ? 1 : 0
  rule      = aws_cloudwatch_event_rule.every_five_minutes[0].name
  target_id = "keep_warm_${var.name}"
  arn       = module.function.function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  count         = var.keep_warm ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes[0].arn
}